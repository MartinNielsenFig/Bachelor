package com.example.tomas.wisrandroid.Helpers;

import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentPagerAdapter;
import android.text.AndroidCharacter;

import com.example.tomas.wisrandroid.Fragments.QuestionListFragment;
import com.example.tomas.wisrandroid.Model.Question;

public class CustomPagerAdapter extends FragmentPagerAdapter {
    private static int COUNT = 2;

    public CustomPagerAdapter(FragmentManager fm) {
        super(fm);
    }

    @Override
    public Fragment getItem(int position) {
        switch (position) {
            case 0: // Fragment # 0 - This will show FirstFragment
                return QuestionListFragment.newInstance(0, "Page # 1");
            case 1: // Fragment # 0 - This will show FirstFragment different title
                return QuestionListFragment.newInstance(1, "Page # 2");
            case 2: // Fragment # 1 - This will show SecondFragment
                return null;//SecondFragment.newInstance(2, "Page # 3");
            default:
                return null;
        }
    }

    @Override
    public int getCount() {
        return COUNT;
    }
}