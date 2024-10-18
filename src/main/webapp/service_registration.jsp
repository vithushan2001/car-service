<%@ page import="com.services.database.DatabaseConnection" %>
<%@ page import="java.sql.*, java.text.SimpleDateFormat, java.util.Date" %>

<%
    // Check if the user is authenticated
    String username = (String) request.getSession().getAttribute("username");
    if (username == null) {
        // If the user is not authenticated, redirect to the login page
        response.sendRedirect("index.jsp");
        return;
    }

    // Handle form submission
    if (request.getParameter("submit") != null) {
        // Get form data
        String dateString = request.getParameter("date");
        String timeString = request.getParameter("preferred-time");
        String location = request.getParameter("preferred-location");
        String mileageStr = request.getParameter("current-mileage");
        String vehicleNo = request.getParameter("vehicle-registration");
        String message = request.getParameter("message");

        try {
            // Convert date and time
            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
            SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm:ss");

            Date parsedDate = dateFormat.parse(dateString);
            Date parsedTime = timeFormat.parse(timeString);

            java.sql.Date sqlDate = new java.sql.Date(parsedDate.getTime());
            java.sql.Time sqlTime = new java.sql.Time(parsedTime.getTime());

            // Convert mileage to integer
            int mileage = Integer.parseInt(mileageStr);

            // Insert into database
            try (DatabaseConnection dbConnection = new DatabaseConnection();
                 Connection connection = dbConnection.getConnection();
                 PreparedStatement preparedStatement = connection.prepareStatement(
                         "INSERT INTO vehicle_service (date, time, location, vehicle_no, mileage, message, username) VALUES (?, ?, ?, ?, ?, ?, ?)")) {

                // Set parameters
                preparedStatement.setDate(1, sqlDate);
                preparedStatement.setTime(2, sqlTime);
                preparedStatement.setString(3, location);
                preparedStatement.setString(4, vehicleNo);
                preparedStatement.setInt(5, mileage);
                preparedStatement.setString(6, message);
                preparedStatement.setString(7, username);

                // Execute query
                int rowsAffected = preparedStatement.executeUpdate();

                // Handle success or failure
                if (rowsAffected > 0) {
                    response.sendRedirect("service_registration.jsp?msg=success");
                } else {
                    response.sendRedirect("service_registration.jsp?msg=failure");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("service_registration.jsp?msg=exception");
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Service Reservation</title>
    <style>
        /* Same styling as before */
        #service {
            text-align: center;
            padding: 50px;
            font-family: Arial;
        }
        #reservation-form {
            max-width: 600px;
            margin: 0 auto;
            background-color: #fff;
            padding: 20px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            border-radius: 5px;
        }
        label, input, select, textarea, button {
            width: 100%;
            padding: 10px;
            margin-top: 5px;
            margin-bottom: 15px;
            box-sizing: border-box;
        }
        button {
            background-color: #d9534f;
            color: white;
            border: none;
            cursor: pointer;
            font-size: 16px;
        }
        button:hover {
            background-color: #c9302c;
        }
        #date-error {
            color: red;
        }
    </style>
</head>
<body>
    <section id="service">
        <form id="reservation-form" method="post" action="">
            <input type="hidden" id="username" name="username" value="<%= username %>">
            <label for="date">Date</label>
            <input type="date" name="date" id="date" required>
            <span id="date-error"></span>

            <label for="preferred-time">Preferred Time</label>
            <select id="preferred-time" name="preferred-time">
                <option value="10:00:00">10 AM</option>
                <option value="11:00:00">11 AM</option>
                <option value="12:00:00">12 PM</option>
            </select>

            <label for="preferred-location">Preferred Location</label>
            <select id="preferred-location" name="preferred-location">
                <!-- Options remain the same -->
            </select>

            <label for="vehicle-registration">Vehicle Registration Number</label>
            <input type="text" id="vehicle-registration" name="vehicle-registration" required>

            <label for="current-mileage">Current Mileage</label>
            <input type="number" id="current-mileage" name="current-mileage" required>

            <label for="message">Message</label>
            <textarea id="message" name="message"></textarea>

            <button type="submit" name="submit">Submit</button>
        </form>
    </section>

    <script>
        // Date input validation logic remains the same
        var dateInput = document.getElementById('date');

        function isSunday(date) {
            return date.getDay() === 0; // Sunday is 0 in JavaScript's date.getDay()
        }

        var currentDate = new Date().toISOString().split('T')[0]; // Get current date in YYYY-MM-DD format
        dateInput.min = currentDate;

        function validateDate() {
            var selectedDate = new Date(dateInput.value);
            var currentDate = new Date();

            if (isSunday(selectedDate) || selectedDate < currentDate) {
                document.getElementById('date-error').innerText = 'Please select a valid date (after today and not a Sunday).';
                dateInput.value = ''; // Clear invalid date
            } else {
                document.getElementById('date-error').innerText = ''; // Clear error message
            }
        }

        dateInput.addEventListener('change', validateDate);
    </script>
</body>
</html>
