package com.chatapp.service;

import java.io.IOException;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;

import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;

public class AIChatService {
    private static final String API_KEY = "YOUR_OPENAI_API_KEY"; // Replace with your actual API Key
    private static final String API_URL = "https://api.openai.com/v1/chat/completions";

    private static final OkHttpClient client = new OkHttpClient();
    private static final Gson gson = new Gson();

    public static String getAIResponse(String userMessage) {
        // Construct JSON request body
        JsonObject requestBody = new JsonObject();
        requestBody.addProperty("model", "gpt-3.5-turbo");

        // Creating a JSON array for messages
        JsonArray messages = new JsonArray();
        JsonObject userMessageObj = new JsonObject();
        userMessageObj.addProperty("role", "user");
        userMessageObj.addProperty("content", userMessage);
        messages.add(userMessageObj);

        requestBody.add("messages", messages);
        requestBody.addProperty("max_tokens", 100);

        RequestBody body = RequestBody.create(
                gson.toJson(requestBody),
                MediaType.get("application/json; charset=utf-8")
        );

        // Construct HTTP request
        Request request = new Request.Builder()
                .url(API_URL)
                .header("Authorization", "Bearer " + API_KEY)
                .header("Content-Type", "application/json")
                .post(body)
                .build();

        try (Response response = client.newCall(request).execute()) {
            if (!response.isSuccessful()) {
                return "Error: Unable to fetch AI response.";
            }

            // Parse response
            JsonObject jsonResponse = gson.fromJson(response.body().string(), JsonObject.class);
            JsonArray choices = jsonResponse.getAsJsonArray("choices");
            if (choices != null && choices.size() > 0) {
                return choices.get(0).getAsJsonObject().get("message").getAsJsonObject().get("content").getAsString();
            }
        } catch (IOException e) {
            e.printStackTrace();
            return "Error: AI service is not available.";
        }

        return "No response from AI.";
    }
}
