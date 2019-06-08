package com.google.codeu.servlets;

import java.io.IOException;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.users.UserService;
import com.google.appengine.api.users.UserServiceFactory;
import com.google.codeu.data.Datastore;
import com.google.codeu.data.User;
import org.jsoup.Jsoup;
import org.jsoup.safety.Whitelist;



/**
 * Handles fetching and saving user data.
 */
@WebServlet("/about")
public class AboutMeServlet extends HttpServlet{

  private Datastore datastore;

  @Override
  public void init() {
    datastore = new Datastore();
  }

  /**
   * Gets the "about me" data for a specific user
   */
  @Override
  public void doGet(HttpServletRequest request, HttpServletResponse response)
  throws IOException {
    // sets the response type, as it can be interpreterd in many different ways
    response.setContentType("text/html");

    String user = request.getParameter("user");
    // case of invalid of no user
    if (user == null || user.equals("")) {
      return;
    }

    User userData = datastore.getUser(user);

    if(userData == null || userData.getAboutMe() == null) {
      return;
    }

    response.getOutputStream().println(userData.getAboutMe());;
  }

  @Override
  public void doPost(HttpServletRequest request, HttpServletResponse response)
  throws IOException {
    // get the current user
    UserService userService = UserServiceFactory.getUserService();
    // if the user is not logged return to index
    if (!userService.isUserLoggedIn()) {
      response.sendRedirect("/index.html");
      return;
    }

    String userEmail = userService.getCurrentUser().getEmail();
    String aboutMe = Jsoup.clean(request.getParameter("about-me"), Whitelist.none());

    User user = new User(userEmail, aboutMe);
    datastore.storeUser(user);

    response.sendRedirect("/user-page.html?user=" + userEmail);
  }
}
