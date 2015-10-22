package com.example.tomas.wisrandroid.Helpers;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentPagerAdapter;
import android.text.AndroidCharacter;

import com.example.tomas.wisrandroid.Fragments.ChatFragment;
import com.example.tomas.wisrandroid.Fragments.QuestionListFragment;
import com.example.tomas.wisrandroid.Fragments.SelectedQuestionFragment;
import com.example.tomas.wisrandroid.Model.Question;

import java.lang.reflect.Array;
import java.util.ArrayList;

public class CustomPagerAdapter extends FragmentPagerAdapter {
    private static int COUNT = 3;
    private String _id;
    private QuestionListFragment mQuestionFragment = null;
    private ChatFragment mChatFragment = null;
    private SelectedQuestionFragment mSelectedQuestionFragment = null;

    public CustomPagerAdapter(FragmentManager fm, String id) {
        super(fm);
        this._id = id;
    }

    @Override
    public Fragment getItem(int position) {
        switch (position) {
            case 0:
                if(mQuestionFragment == null)
                {
                    mQuestionFragment = QuestionListFragment.newInstance(0, "Page # 1", _id);
                    mQuestionFragment.setRetainInstance(true);
                }
                return mQuestionFragment;
            case 1:
                if(mSelectedQuestionFragment == null)
                {
                    mSelectedQuestionFragment = SelectedQuestionFragment.newInstance(0,"page # 2");
                    mSelectedQuestionFragment.setRetainInstance(true);
                }
                return mSelectedQuestionFragment;
            case 2:
                if(mChatFragment == null)
                {
                    mChatFragment = ChatFragment.newInstance(0,"page # 2");
                    mChatFragment.setRetainInstance(true);
                }
                return mChatFragment;
            default:
                return null;
        }
    }

    @Override
    public int getCount() {
        return COUNT;
    }
}