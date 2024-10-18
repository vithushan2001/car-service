<%@ page import="com.services.authentication.AuthenticationUtil" %>
<%
    // Check if the user is authenticated, otherwise redirect to the login page
    if (!AuthenticationUtil.isAuthenticated(request)) {
        response.sendRedirect("index.jsp"); // Redirect to login page
        return;
    }
%>
<%@ page import="com.services.database.*" %>
<%@ page import="java.sql.*" %>
<%@ include file="structure.jsp" %>

<%
    // Initialize the DatabaseConnection object
    DatabaseConnection dbConnection = new DatabaseConnection();
    Connection connection = null;

    // Check if there is a delete request
    String bookingId = request.getParameter("bookingId");
    String deleteParam = request.getParameter("delete");

    if (deleteParam != null && bookingId != null) {
        try {
            connection = dbConnection.getConnection();
            PreparedStatement ps = connection.prepareStatement("DELETE FROM vehicle_service WHERE booking_id = ?");
            ps.setString(1, bookingId);
            int rowsAffected = ps.executeUpdate();
            ps.close();

            // Provide feedback to the user
            if (rowsAffected > 0) {
                response.sendRedirect("delete_registration.jsp?msg=success"); // Redirect after successful deletion
            } else {
                response.sendRedirect("delete_registration.jsp?msg=notfound"); // Handle case when no records are found to delete
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("delete_registration.jsp?msg=failure");
        } finally {
            dbConnection.closeConnection(connection);
        }
        return;
    }

    try {
        connection = dbConnection.getConnection();
        String username = (String) request.getSession().getAttribute("username");

        PreparedStatement preparedStatement = connection.prepareStatement(
            "SELECT * FROM vehicle_service WHERE username = ? AND date >= ?"
        );
        preparedStatement.setString(1, username);
        preparedStatement.setDate(2, java.sql.Date.valueOf(java.time.LocalDate.now()));

        ResultSet resultSet = preparedStatement.executeQuery();

        // Display the reservations table if records are found
        if (resultSet.next()) {
%>
<style>
    body {
        font-family: Arial, sans-serif;
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

    td {
        background-color: #f9f9f9;
    }

    button {
        background-color: #d9534f;
        color: white;
        padding: 8px 12px;
        border: none;
        border-radius: 3px;
        cursor: pointer;
        font-size: 14px;
    }

    button:hover {
        background-color: #c9302c;
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
            <th>Action</th>
        </tr>
    </thead>
    <tbody>
<%
        do {
%>
        <tr>
            <td><%= resultSet.getString("booking_id") %></td>
            <td><%= resultSet.getDate("date") %></td>
            <td><%= resultSet.getTime("time") %></td>
            <td><%= resultSet.getString("location") %></td>
            <td><%= resultSet.getString("vehicle_no") %></td>
            <td><%= resultSet.getString("mileage") %></td>
            <td><%= resultSet.getString("message") %></td>
            <td>
                <form action="delete_registration.jsp" method="post" onsubmit="return confirm('Are you sure you want to delete this booking?');">
                    <input type="hidden" name="bookingId" value="<%= resultSet.getString("booking_id") %>">
                    <button type="submit" name="delete">Delete</button>
                </form>
            </td>
        </tr>
<%
        } while (resultSet.next());
%>
    </tbody>
</table>

<%
        } else {
%>
    <p style="text-align: center; color: #333;">No upcoming reservations found.</p>
<%
        }
        resultSet.close();
        preparedStatement.close();
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        dbConnection.closeConnection(connection);
    }
%>
