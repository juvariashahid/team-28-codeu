/*
 * Copyright 2019 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Usage:
 *   - Forward to this page with parameters plus an attribute called "from",
 *      which should contain the URL one is in. Then this page will get the
 *      refresh token, and then redirect to the original page.
 *   - Future features: Less isAuthorized and logs. One will only call one
 *      function to do the above thing.
 */

package com.google.codeu.servlets;

import com.google.appengine.api.users.UserService;
import com.google.appengine.api.users.UserServiceFactory;
import java.io.FileNotFoundException;
import java.io.IOException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Serializable;
import java.util.Collections;
import java.util.List;
import java.math.BigInteger;
import java.security.SecureRandom;

import com.google.api.client.http.HttpTransport;
import com.google.api.client.extensions.appengine.datastore.AppEngineDataStoreFactory;
import com.google.api.client.extensions.appengine.http.UrlFetchTransport;
import com.google.api.client.json.JsonFactory;
import com.google.api.client.json.jackson2.JacksonFactory;
import com.google.api.client.auth.oauth2.TokenResponse;
import com.google.api.client.auth.oauth2.TokenErrorResponse;
import com.google.api.client.auth.oauth2.TokenResponseException;
import com.google.api.client.auth.oauth2.CredentialRefreshListener;
import com.google.api.client.auth.oauth2.Credential;

import com.google.api.services.calendar.Calendar;
import com.google.api.services.calendar.CalendarScopes;

import com.google.api.client.googleapis.auth.oauth2.GoogleAuthorizationCodeFlow;
import com.google.api.client.googleapis.auth.oauth2.GoogleClientSecrets;


/**
 * Redirects the user to the Google login page or their page if they're already logged in.
 */
//@WebServlet( urlPatterns = {"/OAuth2", "/refreshToken"}, displayName = "Connecting to Google API...")
@WebServlet( "/dashboard/credential" )
public class CredentialServlet extends HttpServlet {

    private static final String CREDENTIALS_FILE_PATH = "/credentials.json";
    private static final HttpTransport HTTP_TRANSPORT = new UrlFetchTransport();
    private static final JsonFactory JSON_FACTORY = JacksonFactory.getDefaultInstance(); //JsonFactory is an abstract class, so here needs a subclass for it.
    private static final AppEngineDataStoreFactory DATA_STORE_FACTORY = AppEngineDataStoreFactory.getDefaultInstance(); //To maintain data manually, specificly for tokens.

    /*
       The flow is the overall class for google authorization classes and methods.
    */
    private static GoogleAuthorizationCodeFlow flow = null;

    /*
       To initialize flow, GoogleAuthorizationCodeFlow.
    */
    @Override
    public void init(){
        List<String> SCOPES = Collections.singletonList(CalendarScopes.CALENDAR);

        // Load client secrets.
        InputStream in = CredentialServlet.class.getResourceAsStream(CREDENTIALS_FILE_PATH);
        if (in == null) {
            //throw new FileNotFoundException("Resource not found: " + CREDENTIALS_FILE_PATH);
            System.err.println("Resource not found: " + CREDENTIALS_FILE_PATH);
            return;
        }
        try{
            //GoogleCredential credential = GoogleCredential.fromStream(in).createScoped(SCOPES); //for service account with service account keys
            GoogleClientSecrets clientSecrets = GoogleClientSecrets.load(JSON_FACTORY, new InputStreamReader(in)); //for oauth2 to get clients' id/file

            flow = new GoogleAuthorizationCodeFlow.Builder( HTTP_TRANSPORT, JSON_FACTORY, clientSecrets, SCOPES)
                    .setDataStoreFactory( DATA_STORE_FACTORY )
                    .setCredentialCreatedListener(new GoogleAuthorizationCodeFlow.CredentialCreatedListener() {
                        @Override
                        public void onCredentialCreated(Credential credential, TokenResponse tokenResponse) throws IOException {
                            UserService userService = UserServiceFactory.getUserService();
                            String userId = userService.getCurrentUser().getUserId();
                            System.out.println("User "+ userId +": OnCredentialCreated" );
                            if( tokenResponse.getRefreshToken() == null ){
                                System.err.println( "OnCredentialCreated: refreshToken is null");
                                return;
                            }
            /*  To maintain the tokens in DATA_STORE_FACTORY. The reason to keep this part is for being as reference once we needed it.
            DATA_STORE_FACTORY.getDataStore("user").set(userId+"_token", tokenResponse.getRefreshToken());
            */
                        }
                    }).addRefreshListener(new CredentialRefreshListener() {
                        @Override
                        public void onTokenResponse(Credential credential, TokenResponse tokenResponse) throws IOException {
                            UserService userService = UserServiceFactory.getUserService();
                            String userId = userService.getCurrentUser().getUserId();
                            System.out.println("User "+ userId +": OnTokenRefreshed" );
                            if( tokenResponse.getRefreshToken() == null ){
                                System.err.println( "OnTokenRefreshed: refreshToken is null");
                                return;
                            }
                        }

                        /*
                            This error usually causes by changed or deleted authorization.
                         */
                        @Override
                        public void onTokenErrorResponse(Credential credential, TokenErrorResponse tokenErrorResponse) throws IOException {
                            System.err.println("OAuth2 Token Error:" + tokenErrorResponse );
                        }
                    }).setAccessType("offline") //set offline for refresh token
                    .build();
        }catch(IOException e){
        }

    }

    @Override
    public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        //For there's LoginFilter to make sure the user has logged in.
        UserService userService = UserServiceFactory.getUserService();
        String userId = userService.getCurrentUser().getUserId(); //unique

    /*
      Record the previous url
      //parameters are the GET variables, while attributes are variables sent by server-side. Objects are fine as attribute.
    if(DATA_STORE_FACTORY.getDataStore("OAuth2Referer").get(userId) == null ){
      String referer = "/index.html";
      if( request.getParameter("referer") != null && !request.getParameter("referer").equals("") ) referer = request.getParameter("referer");
      DATA_STORE_FACTORY.getDataStore("OAuth2Referer").set(userId, referer);
      System.out.println( "First entered Credential from: " +  referer);
    }
    */

        Credential credential = flow.loadCredential(userId);
        boolean authorized = credential != null;
        if( authorized ){
            try{
                if( credential.refreshToken() == false ) authorized = false;  //Correctly authorized?
            }catch( TokenResponseException e ){
                //System.err.println( "refreshToken got TokenResponseException: " + e );
                //This would invoke onTokenErrorResponse, which would also log down the error
                authorized = false;
            }
        }

        request.getSession().setAttribute("authorized", authorized);

        // If the user has already authorized, redirect to their page
        if( !authorized ){
      /*
         The Authorization method will redirect to this page with GET query string
         If this user has authorized but not been recorded, it will direct to get the access code.
       */
            if( request.getParameter("code") == null ){
                String state = new BigInteger(130, new SecureRandom()).toString(32);
                request.getSession().setAttribute("OAuthState", state);
                String OAuth2Url = flow.newAuthorizationUrl()
                        .setRedirectUri(request.getRequestURL().toString())
                        .setState( state ) //against cross-site request forgery
                        .build(); //build for string. otherwise, it'd just be object.
                response.sendRedirect(OAuth2Url);
                return;
            }

            Object state =  request.getSession().getAttribute("OAuthState");
            request.getSession().removeAttribute("OAuthState");
            if( state == null || state.toString().equals(request.getParameter("state")) == false ){
                System.err.println("Got ross-site request forgery in OAuth");
                return;
            }

      /*
        Through GET query string to get the Authorization code for attaining tokens.
        Question/Concern: Should we check whether the return tokens match the format from document?
                          And check whether this token is valid.
      */
            TokenResponse tokenResponse = requestAccessToken( request.getRequestURL().toString(), request.getParameter("code") );
            if( tokenResponse.getRefreshToken() == null ){
                DATA_STORE_FACTORY.getDataStore("OAuth2Referer").delete(userId);
                response.sendRedirect("/error/authorization-token-failed.html");
                return;
            }

            // Restore the token including of refresh token for further use and isAuthorized check.
            flow.createAndStoreCredential(tokenResponse, userId);
            request.getSession().setAttribute("authorized", true);
        }

        // When using response.sendRedirect, saving(?) something like response.getOutputStream().println(json) will make a bug like it has been committed.
    /*
    Serializable refererURL = DATA_STORE_FACTORY.getDataStore("OAuth2Referer").get(userId);
    DATA_STORE_FACTORY.getDataStore("OAuth2Referer").delete(userId);
    System.out.println("Leaving from Credential to referer = " + refererURL);
    */
        response.sendRedirect("/dashboard.html");
    }

    /*
        Get Calendar for requesting calendar data of the user defined by userId.
     */
    public static Calendar getCalendar( String userId )
            throws IOException, FileNotFoundException{
        Credential credential = flow.loadCredential(userId);
        return new Calendar.Builder(
                HTTP_TRANSPORT, JSON_FACTORY, flow.loadCredential(userId))
                .setApplicationName("CodeU team28")
                .build();
    }

    /********Private functions********/

    private TokenResponse requestAccessToken( String RedirectUri, String code )
            throws TokenResponseException, IOException{
        try {
            return flow.newTokenRequest( code )
                    .setRedirectUri( RedirectUri )
                    .execute();
        }catch (TokenResponseException e) {
            //I think this error should stop this user to login until fixed.
            if (e.getDetails() != null) {
                System.err.println("Error: " + e.getDetails().getError());
                if (e.getDetails().getErrorDescription() != null) {
                    System.err.println(e.getDetails().getErrorDescription());
                }
                if (e.getDetails().getErrorUri() != null) {
                    System.err.println(e.getDetails().getErrorUri());
                }
            } else {
                System.err.println(e.getMessage());
            }
        }
        return null;
    }
}