<%@ page import="com.services.authentication.AuthenticationUtil" %>
<%@ page import="com.services.database.DatabaseConnection" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.SQLException" %>
<%@ include file="structure.jsp" %>

<%
    // Ensure the user is authenticated
    if (!AuthenticationUtil.isAuthenticated(request)) {
        // If not authenticated, redirect to the login page
        response.sendRedirect("index.jsp");
        return; // Stop further execution
    }

    // Retrieve the username from the session
    String username = (String) request.getSession().getAttribute("username");

    // Check if the username exists in the session
    if (username == null || username.isEmpty()) {
        response.sendRedirect("index.jsp"); // Redirect if session has no username
        return;
    }

    Connection connection = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        // Initialize the database connection
        DatabaseConnection dbConnection = new DatabaseConnection();
        connection = dbConnection.getConnection();

        // Query to fetch the user's vehicle service records
        String query = "SELECT * FROM vehicle_service WHERE username=?";
        ps = connection.prepareStatement(query);
        ps.setString(1, username);
        rs = ps.executeQuery();

        if (rs.next()) {
%>
            <style>
                body {
                    font-family: Arial;
                    background-color: #f4f4f4;
                    margin: 0;
                    padding: 0;
                }
                table {
                    width: 80%;
                    margin: 20px auto;
                    border-collapse: collapse;
                    background-color: #fff;
                    box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
                    border-radius: 5px;
                }
                th, td {
                    border: 1px solid #ddd;
                    padding: 10px;
                    text-align: left;
                }
                th {
                    background-color: #333;
                    color: #fff;
                }
            </style>

            <table>
                <thead>
                    <tr>
                        <th>Booking ID</th>
                        <th>Date</th>
                        <th>Time</th>
                        <th>Location</th>
                        <th>Vehicle Number</th>
                        <th>Mileage</th>
                        <th>Message</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    do {
                    %>
                    <tr>
                        <td><%= rs.getString(1) %></td>
                        <td><%= rs.getString(2) %></td>
                        <td><%= rs.getString(3) %></td>
                        <td><%= rs.getString(4) %></td>
                        <td><%= rs.getString(5) %></td>
                        <td><%= rs.getString(6) %></td>
                        <td><%= rs.getString(7) %></td>
                    </tr>
                    <%
                    } while (rs.next());
                    %>
                </tbody>
            </table>
<%
        } else {
            // If no reservations are found, show a message
%>
            <p style="color: black; text-align: center;">No reservations found.</p>
<%
        }
    } catch (SQLException e) {
        // Log the error (in production, logging should be done properly)
        e.printStackTrace();
        // Show a generic error message to the user
%>
        <p style="color: red; text-align: center;">An error occurred while fetching your reservations. Please try again later.</p>
<%
    } finally {
        // Ensure resources are closed properly
        if (rs != null) {
            try { rs.close(); } catch (SQLException ignored) {}
        }
        if (ps != null) {
            try { ps.close(); } catch (SQLException ignored) {}
        }
        if (connection != null) {
            try { connection.close(); } catch (SQLException ignored) {}
        }
    }
%>
