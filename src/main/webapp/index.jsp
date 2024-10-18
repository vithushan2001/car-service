<%@ page import="java.io.*, java.util.*" %>

<%
    Properties props = new Properties();
    try (InputStream input = getServletContext().getResourceAsStream("/WEB-INF/authorization.properties")) {
        if (input == null) {
            throw new FileNotFoundException("Authorization properties file not found");
        }
        props.load(input);
    } catch (IOException e) {
        e.printStackTrace();
        throw new ServletException("Error loading authorization properties file", e);
    }
    
    // Prepare the OAuth authorization URL
    String authEndpoint = props.getProperty("oauth.auth_endpoint");
    String clientId = props.getProperty("oauth.client_id");
    String redirectUri = URLEncoder.encode(props.getProperty("oauth.redirect_uri"), "UTF-8");
    String scope = URLEncoder.encode(props.getProperty("oauth.scope"), "UTF-8");
    String responseType = URLEncoder.encode(props.getProperty("oauth.response_type"), "UTF-8");

    String authUrl = String.format("%s?scope=%s&response_type=%s&redirect_uri=%s&client_id=%s",
                                   authEndpoint, scope, responseType, redirectUri, clientId);
%>

<!DOCTYPE html>
<html>
<head>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f0f0f0;
            margin: 0;
            display: flex;
            align-items: center;
            justify-content: center;
            height: 100vh;
            background-image: url('images/Car.jpg');
            background-size: cover;
            background-position: center center;
            background-repeat: no-repeat;
        }

        .login-page {
            display: flex;
            justify-content: flex-end;
            width: 100%;
            margin-right: 200px;
            align-items: center;
        }

        .form {
            background-color: #15305c;
            padding: 10px;
            border-radius: 5px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            min-width: 350px;
            min-height: 350px;
            display: flex;
            flex-direction: column;
            margin-top: 50px;
        }

        .login {
            text-align: center;
            color: #eee;
        }

        .login-header {
            background-color: #1B1212;
            padding: 20px;
            border-radius: 5px 5px 0 0;
            min-height: 200px;
            justify-content: center;
            align-items: center;
        }

        .login-header h1 {
            margin: 0;
            font-size: 40px;
            margin-bottom: 50px;
        }

        .login-header p {
            font-size: 16px;
            color: #fff;
        }

        .login-form {
            text-align: center;
            margin-top: 20px;
        }

        .login-form button {
            background-color: #1B1212;
            color: #eee;
            border: none;
            padding: 15px 30px;
            border-radius: 5px;
            cursor: pointer;
            font-size: 18px;
            transition: background-color 0.3s ease;
        }

        .login-form button a {
            color: #eee;
            text-decoration: none;
        }

        .login-form button:hover {
            background-color: #333;
        }
    </style>
</head>

<body>
    <div class="login-page">
        <div class="form">
            <div class="login">
                <div class="login-header">
                    <h1>DRIVE CARE CONNECT</h1>
                    <p>Your Journey Begins Here</p>
                </div>
            </div>
            <div>
                <form class="login-form">
                    <button>
                        <a href="<%= authUrl %>">Sign In</a>
                    </button>
                </form>
            </div>
        </div>
    </div>
</body>
</html>
