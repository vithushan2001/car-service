<%@ include file="structure.jsp" %>
<%@ page import="java.io.*, java.net.*, java.util.*" %>
<%@ page import="org.json.JSONObject" %>

<%
    // Retrieve tokens from session attributes
    String accessToken = (String) session.getAttribute("access_token");
    String idToken = (String) session.getAttribute("id_token");

    // Load properties from the authorization.properties file
    Properties props = new Properties();
    InputStream input = getServletContext().getResourceAsStream("/WEB-INF/authorization.properties");
    props.load(input);

    String userinfoEndpoint = props.getProperty("oauth.userinfo_endpoint");

    if (accessToken != null && !accessToken.isEmpty()) {
        try {
            // Create connection to the userinfo endpoint
            URL userinfoUrl = new URL(userinfoEndpoint);
            HttpURLConnection connection = (HttpURLConnection) userinfoUrl.openConnection();
            connection.setRequestMethod("GET");
            connection.setRequestProperty("Authorization", "Bearer " + accessToken);

            // Get response code and check for success
            int responseCode = connection.getResponseCode();

            if (responseCode == HttpURLConnection.HTTP_OK) {
                // Read the response
                BufferedReader reader = new BufferedReader(new InputStreamReader(connection.getInputStream()));
                StringBuilder response = new StringBuilder();
                String line;
                while ((line = reader.readLine()) != null) {
                    response.append(line);
                }
                reader.close();

                // Parse JSON response
                JSONObject userInfo = new JSONObject(response.toString());

                // Extract user information
                String username = userInfo.optString("username");
                String name = userInfo.optString("given_name");
                String email = userInfo.optString("email");
                String contactNumber = userInfo.optString("phone_number");
                String lastname = userInfo.optString("family_name");

                JSONObject address = userInfo.optJSONObject("address");
                String country = (address != null) ? address.optString("country") : "N/A";

                // Store username in session
                session.setAttribute("username", username);
%>

<!doctype html>
<html>
<head>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            margin: 0;
            padding: 0;
        }
        .profile-info {
            max-width: 600px;
            margin: 50px auto;
            background-color: white;
            padding: 20px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            border-radius: 5px;
        }
        .info-pair {
            margin-bottom: 15px;
        }
        .info-label {
            font-weight: bold;
            margin-bottom: 5px;
        }
        .info-value {
            color: #d9534f;
        }
    </style>
</head>
<body>
<div class="profile-info">
    <h2 align="center">Profile</h2>
    <div class="info-pair">
        <p class="info-label">USERNAME</p>
        <h4 class="info-value"><%= username %></h4>
    </div>
    <div class="info-pair">
        <p class="info-label">NAME</p>
        <h4 class="info-value"><%= name %></h4>
    </div>
    <div class="info-pair">
        <p class="info-label">EMAIL</p>
        <h4 class="info-value"><%= email %></h4>
    </div>
    <div class="info-pair">
        <p class="info-label">CONTACT NO</p>
        <h4 class="info-value"><%= contactNumber %></h4>
    </div>
    <div class="info-pair">
        <p class="info-label">COUNTRY</p>
        <h4 class="info-value"><%= country %></h4>
    </div>
</div>
</body>
</html>

<%
            } else {
                // Handle error response codes from the userinfo endpoint
                out.println("Failed to fetch user info. HTTP Error Code: " + responseCode);
            }
        } catch (IOException e) {
            // Log the error and show a friendly message
            e.printStackTrace();
            out.println("An error occurred while fetching user info.");
        }
    } else {
        // If no access token, redirect to login page
        response.sendRedirect("index.jsp");
    }
%>
