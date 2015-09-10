package com.example.tomas.wisrandroid.Fragments;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.example.tomas.wisrandroid.R;

/**
 * Created by Tomas on 08-09-2015.
 */
public class FindRoomFragment extends Fragment {

//    private static FindRoomFragment mFindRoomFragment = null;
//
//    public static FindRoomFragment getInstance()
//    {
//        if(mFindRoomFragment == null)
//            mFindRoomFragment = new FindRoomFragment();
//        return mFindRoomFragment;
//    }

    @Override
    public View onCreateView(LayoutInflater inflater,
                             ViewGroup container,
                             Bundle savedInstanceState) {


        return inflater.inflate(R.layout.fragment_findroom, container, false);
    }

    @Override
    public void onStart() {
        super.onStart();
    }

    @Override
    public void onResume() {
        super.onResume();
    }
}
