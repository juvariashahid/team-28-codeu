<!-- Include HEADER.JSP, a JSP file that is shared between calendar.jsp and user-page.jsp -->
<!-- If you want to edit the header of this page, you can edit in header.jsp -->
<%@ include file = "header.jsp" %>

<!-- MAIN CONTENT OF USER PAGE -->
<!DOCTYPE html>
<html>
  <head>
    <title>User Page</title>
    <meta charset="UTF-8">
    <link rel="stylesheet" href="/css/main.css">
    <link rel="stylesheet" href="/css/user-page.css">
    <script src="/js/user-page-loader.js"></script>
  </head>
  <body onload="buildUI();">
   <!--  <nav>
      <ul id="navigation">
        <li><a href="/">Home</a></li>
        <li><a href="/aboutus.html">About Our Team</a></li>
      </ul>
    </nav> -->
    <h1 id="page-title">User Page</h1>

    <div id="about-me-container">Loading...</div>
    <div id="about-me-form" class="hidden">
      <form action="/about" method="POST">
        <textarea name="about-me" placeholder="about me" rows=4 required></textarea>
        <br/>
        <input type="submit" value="Submit">
      </form>
    </div>
    <div id="form-container">
      <form id="message-form" action="/messages" method="POST" class="hidden">
        Enter a new goal:
        <br/>
        Goal Name: <input type="text" name="title"><br>
        Goal Type:
        <select name="fred">
          <option value="Exercise">Exercise</option>
          <option value="Leisure">Leisure</option>
          <option value="Study">Study</option>
          <option value="Social">Social</option>
        </select>
        <br/>
        Amount of time:
        <select name="time">
          <option value="Half-hour">Half-hour</option>
          <option value="1 hour">1 hour</option>
          <option value="2 hours">2 hours</option>
          <option value="3 hours">3 hours</option>
        </select>
        <br/>
        <input type="submit" value="Submit">
      </form>
    </div>
    <hr/>

    <div id="message-container">Loading...</div>

  </body>
</html>


<!-- Include FOOTER.JSP, a JSP file that is shared between calendar.jsp and user-page.jsp -->
<!-- If you want to edit the header of this page, you can edit in footer.jsp -->
<%@ include file = "footer.jsp" %>