<%@ page import="java.io.*, java.net.*, java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="org.json.JSONObject" %>

<%
    // Extract the authorization code and session state from the request parameters
    String authorizationCode = request.getParameter("code");
    String sessionState = request.getParameter("session_state");
    
    // Store the session state
    if (sessionState != null) {
        session.setAttribute("sessionState", sessionState);
    }

    if (authorizationCode == null || authorizationCode.isEmpty()) {
        // Handle the case where the authorization code is missing
        out.println("Authorization code is missing.");
    } else {
        InputStream input = null;
        HttpURLConnection tokenConnection = null;
        BufferedReader tokenReader = null;

        try {
            // Load client credentials and token endpoint from properties
            Properties props = new Properties();
            input = getServletContext().getResourceAsStream("/WEB-INF/authorization.properties");
            props.load(input);

            String clientId = props.getProperty("oauth.client_id");
            String clientSecret = props.getProperty("oauth.client_secret");
            String tokenEndpoint = props.getProperty("oauth.token_endpoint");
            String redirectUri = props.getProperty("oauth.redirect_uri");

            // Construct the request data for token exchange
            String requestData = "code=" + URLEncoder.encode(authorizationCode, "UTF-8") +
                    "&grant_type=authorization_code" +
                    "&client_id=" + URLEncoder.encode(clientId, "UTF-8") +
                    "&client_secret=" + URLEncoder.encode(clientSecret, "UTF-8") +
                    "&redirect_uri=" + URLEncoder.encode(redirectUri, "UTF-8");

            // Create a URL object for the token endpoint and open a connection
            URL tokenUrl = new URL(tokenEndpoint);
            tokenConnection = (HttpURLConnection) tokenUrl.openConnection();
            
            // Set the request method to POST and enable output
            tokenConnection.setRequestMethod("POST");
            tokenConnection.setDoOutput(true);
            
            // Write the request data to the output stream
            try (DataOutputStream tokenOutputStream = new DataOutputStream(tokenConnection.getOutputStream())) {
                tokenOutputStream.writeBytes(requestData);
                tokenOutputStream.flush();
            }

            // Check the response code
            int tokenResponseCode = tokenConnection.getResponseCode();
            if (tokenResponseCode != HttpURLConnection.HTTP_OK) {
                out.println("Failed to retrieve tokens. Response code: " + tokenResponseCode);
                return;
            }

            // Read the response data from the token endpoint
            tokenReader = new BufferedReader(new InputStreamReader(tokenConnection.getInputStream()));
            String tokenInputLine;
            StringBuilder tokenResponse = new StringBuilder();

            while ((tokenInputLine = tokenReader.readLine()) != null) {
                tokenResponse.append(tokenInputLine);
            }

            // Parse the response data as JSON
            String responseDataStr = tokenResponse.toString();
            JSONObject jsonResponse = new JSONObject(responseDataStr);

            // Extract access_token and id_token
            String accessToken = jsonResponse.getString("access_token");
            String idToken = jsonResponse.getString("id_token");

            // Store tokens in session attributes
            session.setAttribute("access_token", accessToken);
            session.setAttribute("id_token", idToken);

            // Redirect to the home page
            response.sendRedirect("home.jsp");

        } catch (Exception e) {
            // Log detailed error for troubleshooting
            System.err.println("Error during token exchange: " + e.getMessage());
            e.printStackTrace();
            out.println("An error occurred while exchanging the authorization code.");
        } finally {
            // Close input stream and connection objects safely
            if (input != null) {
                try {
                    input.close();
                } catch (IOException e) {
                    System.err.println("Failed to close input stream: " + e.getMessage());
                }
            }
            if (tokenReader != null) {
                try {
                    tokenReader.close();
                } catch (IOException e) {
                    System.err.println("Failed to close token reader: " + e.getMessage());
                }
            }
            if (tokenConnection != null) {
                tokenConnection.disconnect();
            }
        }
    }
%>
