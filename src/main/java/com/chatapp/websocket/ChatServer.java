package com.chatapp.websocket;

import java.io.IOException;
import java.util.Set;
import java.util.concurrent.CopyOnWriteArraySet;
import jakarta.websocket.OnClose;
import jakarta.websocket.OnMessage;
import jakarta.websocket.OnOpen;
import jakarta.websocket.Session;
import jakarta.websocket.server.ServerEndpoint;

@ServerEndpoint("/Chat") // WebSocket URL
public class ChatServer {
    private static final Set<Session> clients = new CopyOnWriteArraySet<>();

    @OnOpen
    public void onOpen(Session session) {
        clients.add(session);
        System.out.println("New WebSocket connection: " + session.getId());
    }

    @OnMessage
    public void onMessage(String message, Session session) throws IOException {
    	  System.out.println("📨 Received Message: " + message); // Debug log
        for (Session client : clients) {
            if (client.isOpen()) {
                client.getBasicRemote().sendText(message); // Send message as JSON
            }
        }
    }


    @OnClose
    public void onClose(Session session) {
        clients.remove(session);
        System.out.println("Connection closed: " + session.getId());
    }
}
