package com.example.tomas.wisrandroid.Fragments;

import android.content.pm.PackageInstaller;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Toast;

import com.example.tomas.wisrandroid.R;
import com.facebook.AccessToken;


public class LoginFragment extends Fragment{

//    private static LoginFragment mLoginFragment = null;
//
//    public static LoginFragment getInstance()
//    {
//        if(mLoginFragment == null)
//            mLoginFragment = new LoginFragment();
//        return mLoginFragment;
//    }

    @Override
    public View onCreateView(LayoutInflater inflater,
                             ViewGroup container,
                             Bundle savedInstanceState) {

        return inflater.inflate(R.layout.fragment_login, container, false);
    }

    @Override
    public void onResume() {
        super.onResume();
    }
}
