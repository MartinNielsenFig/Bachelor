package com.example.tomas.wisrandroid.Helpers;

import com.example.tomas.wisrandroid.Model.ErrorCodes;
import com.google.gson.JsonDeserializationContext;
import com.google.gson.JsonDeserializer;
import com.google.gson.JsonElement;
import com.google.gson.JsonParseException;

import java.lang.reflect.Type;

public class ErrorCodesDeserializer  implements JsonDeserializer<ErrorCodes> {

    @Override
    public ErrorCodes deserialize(JsonElement element, Type arg1, JsonDeserializationContext arg2) throws JsonParseException {
        int key = element.getAsInt();
        return ErrorCodes.fromKey(key);
    }

}
