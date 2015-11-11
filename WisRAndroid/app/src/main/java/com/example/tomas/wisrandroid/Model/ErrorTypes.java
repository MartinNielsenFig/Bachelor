package com.example.tomas.wisrandroid.Model;

public enum ErrorTypes {
    Ok (0),
    Error (1),
    Complicated (2)
    ;

    private final int ErrorTypeKey;

    ErrorTypes(int errorTypeKey)
    {
        this.ErrorTypeKey = errorTypeKey;
    }

    public int getErrorTypeKey() {
        return this.ErrorTypeKey;
    }

    public static ErrorTypes fromKey(int key) {
        for(ErrorTypes type : ErrorTypes.values()) {
            if(type.getErrorTypeKey() == key) {
                return type;
            }
        }
        return null;
    }
}
