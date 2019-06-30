<!-- Include HEADER.JSP, a JSP file that is shared between calendar.jsp and user-page.jsp -->
<!-- If you want to edit the header of this page, you can edit in header.jsp -->
<%@ include file = "header.jsp" %>

<!-- MAIN CONTENT OF USER PAGE -->
<h1> User Page </h1>
<div id="about-me-container">Loading...</div>
    <div id="about-me-form" class="hidden">
      <form action="/about" method="POST">
        <textarea name="about-me" placeholder="about me" rows=4 required></textarea>
        <br/>
        <input type="submit" value="Submit">
      </form>
    </div>

    <form id="message-form" action="/messages" method="POST" class="hidden">
      <!-- Enter a title:
      <br/>
      <textarea name="title" id="message-input"></textarea>
      <br/>
      Enter a new message:
      <br/>
      <textarea name="content" id="message-input"></textarea>
      <br/> -->
      First name: <input type="text" name="fname"><br>
      Last name: <input type="text" name="lname"><br>
      <input type="submit" value="Submit">
    </form>
    <hr/>

    <div id="message-container">Loading...</div>


<!-- Include FOOTER.JSP, a JSP file that is shared between calendar.jsp and user-page.jsp -->
<!-- If you want to edit the header of this page, you can edit in footer.jsp -->
<%@ include file = "footer.jsp" %>