package com.example.tomas.wisrandroid.Fragments;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.example.tomas.wisrandroid.R;

public class ChatFragment extends Fragment {

    public static ChatFragment newInstance(int page, String title) {
        ChatFragment chatFragment = new ChatFragment();

        return chatFragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_chat, container, false);

        return view;
    }

    @Override
    public void onStart() {
        super.onStart();

    }
}
