package com.example.tomas.wisrandroid.Helpers;

import com.example.tomas.wisrandroid.Model.ErrorTypes;
import com.google.gson.JsonDeserializationContext;
import com.google.gson.JsonDeserializer;
import com.google.gson.JsonElement;
import com.google.gson.JsonParseException;

import java.lang.reflect.Type;

// Made from guide http://kylewbanks.com/blog/Int-Enum-Mapping-with-GSON
public class ErrorTypesDeserializer  implements JsonDeserializer<ErrorTypes> {

    @Override
    public ErrorTypes deserialize(JsonElement element, Type arg1, JsonDeserializationContext arg2) throws JsonParseException {
        int key = element.getAsInt();
        return ErrorTypes.fromKey(key);
    }

}
