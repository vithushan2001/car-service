<%@ page import="javax.servlet.http.HttpSession" %>
<%
    HttpSession session = request.getSession(false); // Retrieve session if it exists, otherwise return null
    String sessionState = session != null ? (String) session.getAttribute("sessionState") : null;
    String client_id = "Yb0SLskZKAQHsgNs2ffFQ84evf0a";
    String postLogoutRedirectUri = "http://localhost:8082/Drive_Care_Connect/index.jsp";

    // If sessionState is null, ensure it's handled to avoid passing null value to the form.
    if (sessionState == null) {
        response.sendRedirect("index.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Drive Care Connect</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #333;
            margin: 0;
            padding: 0;
        }
        .navbar {
            background-color: #000;
            display: flex;
            justify-content: space-around;
            align-items: center;
            padding: 10px 0;
        }
        .nav-link {
            text-decoration: none;
            color: #fff;
            font-size: 16px;
            margin: 0 20px;
        }
        .nav-link.active {
            background-color: #555;
            border-radius: 3px;
            padding: 5px 10px;
        }
        #logout-btn {
            background-color: #d9534f;
            color: white;
            padding: 8px 12px;
            border: none;
            border-radius: 3px;
            cursor: pointer;
            font-size: 14px;
        }
        #logout-btn:hover {
            background-color: #c9302c;
        }
    </style>
</head>
<body>

<div class="navbar">
    <a class="nav-link" href="home.jsp">Profile</a>
    <a class="nav-link" href="service_registration.jsp">Add Reservation</a>
    <a class="nav-link" href="delete_registration.jsp">Upcoming Reservations</a>
    <a class="nav-link" href="view_registration.jsp">View All</a>

    <!-- Logout Form -->
    <form id="logout-form" action="https://api.asgardeo.io/t/vithushan/oidc/logout" method="POST">
        <input type="hidden" name="client_id" value="<%= client_id %>">
        <input type="hidden" name="post_logout_redirect_uri" value="<%= postLogoutRedirectUri %>">
        <input type="hidden" name="state" value="<%= sessionState %>">
        <button id="logout-btn" type="submit">Logout</button>
    </form>
</div>

<!-- Rest of your content -->
</body>
</html>
