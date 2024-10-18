package com.services.authentication;

import javax.servlet.http.HttpServletRequest;
public class AuthenticationUtil {
	  public static boolean isAuthenticated(HttpServletRequest request) {
	        // Check if the user is logged in (e.g., by checking the presence of a session attribute)
	        return request.getSession().getAttribute("username") != null;
	    }

}
