<!-- This is index.jsp. This is essentially the index.html, but with javascript embedded in it -->

<%@ page import="com.google.appengine.api.users.UserService" %>
<%@ page import="com.google.appengine.api.users.UserServiceFactory" %>

<!-- This is the logic that determines if the user is logged in or not
If the user is logged in, redirect to the user-page -->

<%
  UserService userService = UserServiceFactory.getUserService();
  if (userService.isUserLoggedIn()) {
    String username = userService.getCurrentUser().getEmail();
%>
    	<meta http-equiv="Refresh" content="0;user-page.jsp?user=<%= username %>">
 <%   	} %>

<!-- HTML begins here -->
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <title>Team 28</title>
    <link rel="stylesheet" href="/css/main.css">
  </head>
  <body>
  	<!-- Navigation Bar -->
    <nav>
      <ul id="navigation">
        <li><a href="/">Home</a></li>
		<li><a href="/login">Login</a></li>
		<li><a href="/aboutus.html">About Our Team</a></li>
		<!-- Need to add links to all of our projects -->
      </ul>
    </nav>
    <!-- Navigation Bar ends -->

    <!-- Content of the Page -->
     <div class = "main">
        <h1>Time Manager</h1>
      </div>
      <div class = "main">
        <p>This is Team 28's project. Click the links above to login and visit your page.
        You can post messages on your page, and you can visit other user pages if you have
         their URL.</p>
      </div>
     <!-- End of Page Content -->
  </body>
</html>