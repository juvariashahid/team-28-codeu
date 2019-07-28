<!-- Include HEADER.JSP, a JSP file that is shared between calendar.jsp and user-page.jsp -->
<%@ include file = "header.jsp" %>

<head>
<meta charset='utf-8' />
<link href='../packages/core/main.css' rel='stylesheet' />
<link href='../packages/daygrid/main.css' rel='stylesheet' />
<link href='../packages/timegrid/main.css' rel='stylesheet' />
<link href='../packages/list/main.css' rel='stylesheet' />
<script src='../packages/core/main.js'></script>
<script src='../packages/interaction/main.js'></script>
<script src='../packages/daygrid/main.js'></script>
<script src='../packages/timegrid/main.js'></script>
<script src='../packages/list/main.js'></script>
<script src='../packages/google-calendar/main.js'></script>
<script src='./config.js'></script>

<style>

  body {
    margin: 40px 10px;
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

<!-- Beginning of the main content for the calendar page -->
<h1> My Calendar </h1>

      <button id="authorize_button" style="display: none;">Authorize</button>
      <button id="signout_button" style="display: none;">Sign Out</button>

      <pre id="content" style="white-space: pre-wrap;"></pre>

      <div id='loading'>loading...</div>

      <div id='calendar'></div>

<%-- Javescript --%>
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

        /**
         * Print the summary and start datetime/date of the next ten events in
         * the authorized user's calendar. If no events are found an
         * appropriate message is printed.
         */

        function getAllCalenders() {
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

        calendar.render();
      }

      </script>

      <script async defer src="https://apis.google.com/js/api.js"
        onload="this.onload=function(){};handleClientLoad()"
        onreadystatechange="if (this.readyState === 'complete') this.onload()">
      </script>

<!-- Include FOOTER.JSP, a JSP file that is shared between calendar.jsp and user-page.jsp -->
<%@ include file = "footer.jsp" %>
