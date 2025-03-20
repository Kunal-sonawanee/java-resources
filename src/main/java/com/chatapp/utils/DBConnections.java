package com.chatapp.utils;

import java.sql.Connection;
import java.sql.DriverManager;

public class DBConnections {
    private static Connection conn;
    
    public static Connection getConnection() {
        try {
            if (conn == null) {
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/chat_app", "root", "kunal");
                System.out.println("Database Connected!");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return conn;
    }
}
