<!-- Include HEADER.JSP, a JSP file that is shared between calendar.jsp and user-page.jsp -->

<!DOCTYPE html>
<html>
  <head>
    <meta charset='utf-8' />
    <link href='../packages/core/main.css' rel='stylesheet' />
    <link href='../packages/daygrid/main.css' rel='stylesheet' />
    <link href='../packages/timegrid/main.css' rel='stylesheet' />
    <link href='../packages/list/main.css' rel='stylesheet' />
    <link rel="stylesheet" href="/css/user-page.css">
    <link rel="stylesheet" href="/css/main.css">
    <script src="/js/user-page-loader.js"></script>
    <script src='../packages/core/main.js'></script>
    <script src='../packages/interaction/main.js'></script>
    <script src='../packages/daygrid/main.js'></script>
    <script src='../packages/timegrid/main.js'></script>
    <script src='../packages/list/main.js'></script>
    <script src='../packages/google-calendar/main.js'></script>
    <script src='./config.js'></script>
    <style>
        html, body{
          height; 100%;
          margin:40px 10px;
        }
        body {
          
          padding: 0;
          font-family: Arial, Helvetica Neue, Helvetica, sans-serif;
          font-size: 14px;
        }

        #loading {
          display: none;
          position: absolute;
          top: 10px;
          right: 10px;
        }

        #calendar {
          max-width: 900px;
          margin: 0 auto;
        }
    </style>
  </head>
  <body onload="buildUI();">
    <nav>
          <ul id="navigation">
          <!-- <li><a href="/calendar.jsp">myCal</a></li> -->
          <li><a href="/aboutus.html">About Our Team</a></li>
           <li><a href="/user-page.jsp"> My Dashboard</a></li>
          <li><a href="/logout">Logout</a></li>
          </ul>
      </nav>
    <!--  <body onload="buildUI();"> -->
    <!-- USER PAGE -->
    <h1 id="page-title">User Page</h1>

    <div class="row">
      <div class="column">
        <!-- DASHBOARD -->
        <!-- <div id="about-me-container">Loading...</div>
        <div id="about-me-form" class="hidden">
          <form action="/about" method="POST">
            <textarea name="about-me" placeholder="about me" rows=4 required></textarea>
            <br/>
            <input type="submit" value="Submit">
          </form>
        </div> -->
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
            <input onclick ="execute()" type="submit" value="Find a Time for ME!">
            <!-- <button onclick="execute()">Find a Time for Me!</button> -->
          </form>
        </div>
        <hr/>

        <div id="message-container">Loading...</div>
          </div>
          <div class="column" style="background-color:#bbb;">
            <!-- Calendar!!! -->
            <h1> My Calendar </h1>

            <!-- Buttons -->
            <button id="authorize_button" style="display: none;">Authorize and Load My Calendar!</button>
            <button id="signout_button" style="display: none;">Sign Out</button>

            <pre id="content" style="white-space: pre-wrap;"></pre>

            <div id='loading'>loading...</div>

            <div id='calendar'></div>
          </div>
    </div>
    
      <script type="text/javascript">
        var CLIENT_ID = config.CLIENT_ID;
      var API_KEY = config.API_KEY;

      // Array of API discovery doc URLs for APIs used by the quickstart
      var DISCOVERY_DOCS = ["https://www.googleapis.com/discovery/v1/apis/calendar/v3/rest"];

      // Authorization scopes required by the API; multiple scopes can be
      // included, separated by spaces.
      var SCOPES = "https://www.googleapis.com/auth/calendar";

      var authorizeButton = document.getElementById('authorize_button');
      var signoutButton = document.getElementById('signout_button');
      var preContent = document.getElementById('content');
      var calendarEl = document.getElementById('calendar');

      /**
       *  On load, called to load the auth2 library and API client library.
       */
      function handleClientLoad() {
        gapi.load('client:auth2', initClient);
      }

      /**
       *  Initializes the API client library and sets up sign-in state
       *  listeners.
       */
      function initClient() {
        gapi.client.init({
          apiKey: API_KEY,
          clientId: CLIENT_ID,
          discoveryDocs: DISCOVERY_DOCS,
          scope: SCOPES
        }).then(function () {
          // Listen for sign-in state changes.
          gapi.auth2.getAuthInstance().isSignedIn.listen(updateSigninStatus);

          // Handle the initial sign-in state.
          updateSigninStatus(gapi.auth2.getAuthInstance().isSignedIn.get());
          authorizeButton.onclick = handleAuthClick;
          signoutButton.onclick = handleSignoutClick;
        }, function(error) {
          appendPre(JSON.stringify(error, null, 2));
        });
      }

      /**
       *  Called when the signed in status changes, to update the UI
       *  appropriately. After a sign-in, the API is called.
       */
      function updateSigninStatus(isSignedIn) {
        if (isSignedIn) {
          authorizeButton.style.display = 'none';
          signoutButton.style.display = 'block';
          if(calendarEl.firstChild)
          {
              while(calendarEl.firstChild){
                calendarEl.removeChild(calendarEl.firstChild);
              }
              console.log(calendarEl);
          }  
          getAllCalenders();
        } else {
          authorizeButton.style.display = 'block';
          signoutButton.style.display = 'none';
          preContent.innerHTML = '';
        }
      }

      /**
       *  Sign in the user upon button click.
       */
      function handleAuthClick(event) {
        gapi.auth2.getAuthInstance().signIn();
      }

      /**
       *  Sign out the user upon button click.
       */
      function handleSignoutClick(event) {
        gapi.auth2.getAuthInstance().signOut();
        if(calendarEl.firstChild)
        {
            while(calendarEl.firstChild){
              calendarEl.removeChild(calendarEl.firstChild);
            }
            console.log(calendarEl);
        }  
      }

      /**
       * Append a pre element to the body containing the given message
       * as its text node. Used to display the results of the API call.
       *
       * @param {string} message Text to be placed in pre element.
       */
      function appendPre(message) {
        var textContent = document.createTextNode(message + '\n');
        preContent.appendChild(textContent);
      }

      //DISPLAY CALENDAR
      function getAllCalenders() {
        console.log("Hello");
        gapi.client.calendar.calendarList.list({
        }).then(function(response) {
          var listOfCalendars = response.result.items.map(item => item.id);
          // listUpcomingEvents(Array.from(listOfCalendars));
          createFullCalendar(listOfCalendars)
        });
      }

      function listUpcomingEvents(calendarList) {
        appendPre('Upcoming events:');
        for (i = 0; i < calendarList.length; i++) {
          gapi.client.calendar.events.list({
            'calendarId': calendarList[i],
            'timeMin': (new Date()).toISOString(),
            'showDeleted': false,
            'singleEvents': true,
            'maxResults': 10,
            'orderBy': 'startTime'
          }).then(function(response) {
            var events = response.result.items;

            if (events.length > 0) {
              for (i = 0; i < events.length; i++) {
                var event = events[i];
                var when = event.start.dateTime;
                if (!when) {
                  when = event.start.date;
                }
                appendPre(event.summary + ' (' + when + ')')
              }
            }
          });
        }
      }

      function createFullCalendar(eventSources) {
        var newEventSoures = eventSources.map(function (eventID) {
          return {
            googleCalendarId : eventID
          }
        })
        console.log("Response", newEventSoures);
        console.log(calendarEl);

        var calendar = new FullCalendar.Calendar(calendarEl, {

        plugins: [ 'interaction', 'timeGrid', 'list', 'googleCalendar' ],

        defaultView: 'timeGridWeek',

        header: {
          left: 'prev,next today',
          center: 'title',
          right: 'dayGridWeek,dayGridMonth,listYear'
        },

        displayEventTime: false, // don't show the time column in list view

        googleCalendarApiKey: config.API_KEY,

        eventSources: newEventSoures,

        eventClick: function(arg) {
          // opens events in a popup window
          window.open(arg.event.url, 'google-calendar-event', 'width=700,height=600');

          arg.jsEvent.preventDefault() // don't navigate in main tab
        },

        loading: function(bool) {
          document.getElementById('loading').style.display =
            bool ? 'block' : 'none';
        }

      });
        console.log("rendering");
      calendar.render();
      }


      function authenticate() {
        return gapi.auth2.getAuthInstance()
            .signIn({scope: "https://www.googleapis.com/auth/calendar https://www.googleapis.com/auth/calendar.events"})
            .then(function() { console.log("Sign-in successful"); },
                  function(err) { console.error("Error signing in", err); });
      }
      function loadClient() {
        gapi.client.setApiKey(config.API_KEY);
        return gapi.client.load("https://content.googleapis.com/discovery/v1/apis/calendar/v3/rest")
            .then(function() { console.log("GAPI client loaded for API"); },
                  function(err) { console.error("Error loading GAPI client for API", err); });
      }

      // Make sure the client is loaded and sign-in is complete before calling this method.
           function execute() {
              return gapi.client.calendar.events.insert({
                "calendarId": "primary",
                "conferenceDataVersion": 1,
                "maxAttendees": 2,
                "sendNotifications": true,
                "sendUpdates": "all",
                "supportsAttachments": true,
                "resource": {
                  "end": {
                    "dateTime": "2019-08-01T15:00:00.000Z"
                  },
                  "start": {
                    "dateTime": "2019-07-30T10:00:00.000Z"
                  }
                }
              })
                  .then(function(response) {
                          // Handle the results here (response.result has the parsed body).
                          console.log("Response", response);
                          // calendarEl  ="";
                          if(calendarEl.firstChild)
                          {
                              while(calendarEl.firstChild){
                                calendarEl.removeChild(calendarEl.firstChild);
                              }
                              console.log(calendarEl);
                          }                      
                          getAllCalenders();
                          
                        },
                        function(err) { console.error("Execute error", err); });

      }

            var startDate = new Date(),
                  endDate = new Date();
            console.log("start Date: " + startDate);
            console.log("end Date: " + endDate);
              var rootStart = startDate,
                  rootEnd = endDate;  
            function freeBusy(){
            
            return gapi.client.calendar.freebusy.query({
                "resource": {
                  "timeMax": "2019-08-03T10:00:00.000Z",
                  "timeMin": "2019-08-02T05:00:00.000Z",
                  "items": [
                    {
                      "id": "primary"
                    }
                  ],
                  "calendarExpansionMax": 1,
                  "groupExpansionMax": 1,
                  "timeZone": "GMT+0100"
                }
              })
                  .then(function(response) {
                          // Handle the results here (response.result has the parsed body).
                          console.log("freebusy", response);
                          return slotsFromEvents(startDate.toISOString(), response.result.calendars.primary.busy)
                        },
                        function(err) { console.error("Execute error", err); });
               
          }

          var interval = 1, // how big single slot should be (in this case 2 hrs) 
          freeSlots = []; 

          function slotsFromEvents(date,events) {
              events.forEach(function (event, index) { //calculate free from busy times
                  if (index == 0 && startDate.toISOString() < event.start) {
                      freeSlots.push({startDate: startDate.toISOString(), endDate: event.start});
                  }
                  else if (index == 0) {
                      startDate = event.end;
                  }
                  else if (events[index - 1].end < event.start) {
                      freeSlots.push({startDate: events[index - 1].end, endDate: event.start});
                  }

                  if (events.length == (index + 1) && event.end < endDate.toISOString()) {
                      freeSlots.push({startDate: event.end, endDate: endDate.toISOString()});
                  }
              });


              if (events.length == 0) {
                  freeSlots.push({startDate: startDate.toISOString(), endDate: endDate.toISOString()});
              }

              var temp = {}, hourSlots = [];
              freeSlots.forEach(function(free, index) {
                  var freeHours = new Date(free.endDate).getHours() - new Date(free.startDate).getHours(), freeStart = new Date(free.startDate), freeEnd = new Date(free.endDate);
                  while(freeStart.getHours()+freeHours+interval>=0) { // 11 + 4 + 2 >= 0
                      if(freeHours>=interval) {
                          temp.e = new Date(free.startDate);
                          temp.e.setHours(temp.e.getHours()+freeHours);
                          temp.s = new Date(free.startDate);
                          temp.s.setHours(temp.s.getHours()+freeHours-interval);
                          if(temp.s.getHours() >= rootStart.getHours() && temp.e.getHours() <= rootEnd.getHours()) {
                              hourSlots.push({calName: calObj.name, startDate:temp.s, endDate:temp.e});
                              temp = {};
                          }
                      }
                      freeHours--;
                  }
              })
              console.log(freeSlots);
              console.log(hourSlots);

              // callBack(freeSlots, hourSlots);
          }

      gapi.load("client:auth2", function() {
        gapi.auth2.init({client_id: config.CLIENT_ID});
      });
      </script>
      <!--  <button onclick="authenticate().then(loadClient)">authorize and load</button> -->
      <button onclick="execute()">Find a Time for Me!</button>
      <button onclick="freeBusy()">freeBusy</button>



      <!-- </script> -->
    <!-- <script src="/js/dude.js"></script> -->
    <script async defer src="https://apis.google.com/js/api.js"
      onload="this.onload=function(){};handleClientLoad()"
      onreadystatechange="if (this.readyState === 'complete') this.onload()">
    </script>

<!-- Include FOOTER.JSP, a JSP file that is shared between calendar.jsp and user-page.jsp -->
</body>
</html>
