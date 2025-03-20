<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="java.io.*" %>

<%
    // Check if user is logged in
    HttpSession sessionObj = request.getSession(false);
    String username = (sessionObj != null) ? (String) sessionObj.getAttribute("username") : null;

    if (username == null) {
        response.sendRedirect("login.jsp"); // Redirect if not logged in
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chat Room</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            text-align: center;
            background-color: #f4f4f4;
        }
        #chat-box {
            width: 60%;
            height: 400px;
            border: 1px solid #ccc;
            overflow-y: scroll;
            background: #fff;
            margin: 20px auto;
            padding: 10px;
            text-align: left;
        }
        #message-input {
            width: 50%;
            padding: 10px;
        }
        .message {
            padding: 5px;
            border-bottom: 1px solid #ddd;
        }
        .message strong {
            color: #007bff;
        }
        .ai-message {
            color: green;
            font-style: italic;
        }
        .logout-btn {
            display: inline-block;
            margin: 10px;
            padding: 10px 15px;
            background: red;
            color: white;
            text-decoration: none;
            border-radius: 5px;
        }
    </style>
</head>
<body>
    <h2>Welcome, <%= username %>! Chat Room</h2>
    
    <div id="chat-box"></div>
    
    <input type="text" id="message-input" placeholder="Type your message...">
    <button onclick="sendMessage()">Send</button>

    <br><br>
    <a href="Logout" class="logout-btn">Logout</a>

    <script>
    let ws;
    
    function connectWebSocket() {
        if (ws && (ws.readyState === WebSocket.OPEN || ws.readyState === WebSocket.CONNECTING)) {
            return; // Prevent reinitializing an open WebSocket
        }

        ws = new WebSocket("ws://" + window.location.host + "/Chat_app/Chat");

        ws.onopen = function () {
            console.log("Connected to WebSocket Server.");
        };

        ws.onmessage = function (event) {
            let chatBox = document.getElementById("chat-box");
            let newMessage = document.createElement("div");
            newMessage.classList.add("message");
            newMessage.innerHTML = event.data;
            chatBox.appendChild(newMessage);
            chatBox.scrollTop = chatBox.scrollHeight;
        };

        ws.onclose = function () {
            console.log("WebSocket closed. Reconnecting...");
            setTimeout(connectWebSocket, 3000); // Reconnect after 3 seconds
        };

        ws.onerror = function (error) {
            console.log("WebSocket error:", error);
            ws.close(); // Ensure the connection is closed before retrying
        };
    }

    // Start WebSocket connection
    connectWebSocket();

    function sendMessage() {
        let input = document.getElementById("message-input");
        let userMessage = input.value.trim();
        if (userMessage === "") return;

        if (ws.readyState === WebSocket.OPEN) {
            let formattedMessage = "<strong><%= username %>:</strong> " + userMessage;
            ws.send(formattedMessage);
            appendMessage(formattedMessage);
            input.value = "";

            // Send message to AI for response
            fetchAIResponse(userMessage);
        } else {
            alert("WebSocket connection is closed. Trying to reconnect...");
            connectWebSocket();
        }
    }

    function appendMessage(message, isAI = false) {
        let chatBox = document.getElementById("chat-box");
        let newMessage = document.createElement("div");
        newMessage.classList.add("message");
        if (isAI) {
            newMessage.classList.add("ai-message");
        }
        newMessage.innerHTML = message;
        chatBox.appendChild(newMessage);
        chatBox.scrollTop = chatBox.scrollHeight;
    }

    function fetchAIResponse(userMessage) {
        fetch("ChatServlet", {
            method: "POST",
            headers: {
                "Content-Type": "application/x-www-form-urlencoded"
            },
            body: "message=" + encodeURIComponent(userMessage)
        })
        .then(response => response.text())
        .then(aiResponse => {
            let aiMessage = "<strong>AI:</strong> " + aiResponse;
            appendMessage(aiMessage, true);
        })
        .catch(error => console.error("Error fetching AI response:", error));
    }
    </script>
</body>
</html>
