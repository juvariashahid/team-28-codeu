/* Copyright 2019 Google Inc.
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
 */

package com.google.codeu.servlets;
import com.google.api.client.auth.oauth2.Credential;
import com.google.api.client.extensions.appengine.http.UrlFetchTransport;
import com.google.api.client.googleapis.auth.oauth2.GoogleAuthorizationCodeFlow;
import com.google.api.client.googleapis.auth.oauth2.GoogleClientSecrets;
import com.google.api.client.googleapis.extensions.appengine.auth.oauth2.AppIdentityCredential;
import com.google.api.client.googleapis.javanet.GoogleNetHttpTransport;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.JsonFactory;
import com.google.api.client.json.jackson2.JacksonFactory;
import com.google.api.client.util.store.FileDataStoreFactory;
import com.google.api.services.calendar.CalendarScopes;

import java.io.InputStream;
import java.util.Collections;
import com.google.appengine.api.users.UserService;
import com.google.appengine.api.users.UserServiceFactory;
import com.google.api.services.calendar.model.Event;
import com.google.api.services.calendar.model.EventDateTime;
import com.google.api.services.calendar.Calendar;
import com.google.api.client.util.DateTime;
import com.google.codeu.data.Datastore;
import com.google.codeu.data.Message;
import com.google.gson.Gson;
import java.io.IOException;
import java.util.List;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.jsoup.Jsoup;
import org.jsoup.safety.Whitelist;
import com.github.rjeschke.txtmark.Processor;
import com.google.api.client.googleapis.auth.oauth2.GoogleCredential;

/** Handles fetching and saving {@link Message} instances. */
@WebServlet("/messages")
public class MessageServlet extends HttpServlet {

  private Datastore datastore;

  @Override
  public void init() {
    datastore = new Datastore();
  }

  /**
   * Responds with a JSON representation of {@link Message} data for a specific user. Responds with
   * an empty array if the user is not provided.
   */
  @Override
  public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {

    response.setContentType("application/json");

    String user = request.getParameter("user");

    if (user == null || user.equals("")) {
      // Request is invalid, return empty array
      response.getWriter().println("[]");
      return;
    }

    List<Message> messages = datastore.getMessages(user);
    Gson gson = new Gson();
    String json = gson.toJson(messages);

    response.getWriter().println(json);
  }

  /** Stores a new {@link Message}. */
  @Override
  public void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {

    UserService userService = UserServiceFactory.getUserService();
    if (!userService.isUserLoggedIn()) {
      response.sendRedirect("/index.html");
      return;
    }

    String user = userService.getCurrentUser().getEmail();
    String text = Jsoup.clean(request.getParameter("title") , Whitelist.none());
    //String markdown = Processor.process(text);
    String description =  request.getParameter("content");
    Message message = new Message(user, text, description, request.getParameter("time"));
    datastore.storeMessage(message);
    try {
          createEvent(text, description);
    } catch (Exception e) {}
    response.sendRedirect("/user-page.jsp?user=" + user);
  }

  private void createEvent(String summary, String description) throws IOException {
    try {
      Event event = new Event()
      .setSummary(summary)
      .setDescription(description);

      DateTime startDateTime = new DateTime("2019-07-20T09:00:00");
      EventDateTime start = new EventDateTime()
          .setDateTime(startDateTime)
          .setTimeZone("America/Los_Angeles");
      event.setStart(start);

      DateTime endDateTime = new DateTime("2019-07-20T17:00:00");
      EventDateTime end = new EventDateTime()   
          .setDateTime(endDateTime)
          .setTimeZone("America/Los_Angeles");
      event.setEnd(end);

      String calendarId = "primary";
      event = getService().events().insert(calendarId, event).execute();
      System.out.printf(event.getHtmlLink());
    } catch (Exception e) {
      System.out.println("An execption occurred: " + e);
    }
  }

  private Calendar getService() throws Exception {
      final NetHttpTransport HTTP_TRANSPORT = GoogleNetHttpTransport.newTrustedTransport();
        AppIdentityCredential credential =
                new AppIdentityCredential(
                        Collections.singletonList(CalendarScopes.CALENDAR_EVENTS));
        return new Calendar.Builder(HTTP_TRANSPORT,
                JacksonFactory.getDefaultInstance(),
                credential)
                .build();
      }
}
