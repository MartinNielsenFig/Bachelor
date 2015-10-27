package com.example.tomas.wisrandroid.Helpers;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentPagerAdapter;
import android.support.v4.view.ViewPager;
import android.text.AndroidCharacter;

import com.example.tomas.wisrandroid.Activities.RoomActivity;
import com.example.tomas.wisrandroid.Fragments.ChatFragment;
import com.example.tomas.wisrandroid.Fragments.QuestionListFragment;
import com.example.tomas.wisrandroid.Fragments.SelectedQuestionFragment;
import com.example.tomas.wisrandroid.Model.Question;
import com.example.tomas.wisrandroid.Model.Room;

import java.lang.reflect.Array;
import java.util.ArrayList;

public class CustomPagerAdapter extends FragmentPagerAdapter {
    private static int COUNT = 3;
    private final RoomActivity mContext;
    private final Room mRoom;
    private final ViewPager mViewPager;

    public CustomPagerAdapter(RoomActivity context, FragmentManager fm, Room room, ViewPager viewPager) {
        super(fm);
        this.mContext = context;
        this.mRoom = room;
        this.mViewPager = viewPager;
    }

    @Override
    public Fragment getItem(int position) {
        switch (position) {
            case 0:
                if(mContext.getSupportFragmentManager().findFragmentByTag(getFragmentTag( mViewPager.getId(), position)) == null)
                {
                    QuestionListFragment mQLFragment = QuestionListFragment.newInstance(0, "Page # 1", mRoom);
                    mQLFragment.setRetainInstance(true);
                    return mQLFragment;
                }else{
                    return mContext.getSupportFragmentManager().findFragmentByTag(getFragmentTag(mViewPager.getId(), position));
                }

            case 1:
                if(mContext.getSupportFragmentManager().findFragmentByTag(getFragmentTag( mViewPager.getId(), position)) == null) {
                    SelectedQuestionFragment mSQFragment = SelectedQuestionFragment.newInstance(0, "Page # 2");
                    mSQFragment.setRetainInstance(true);
                    return mSQFragment;
                }else{
                    return mContext.getSupportFragmentManager().findFragmentByTag(getFragmentTag(mViewPager.getId(), position));
                }

            case 2:
                if(mContext.getSupportFragmentManager().findFragmentByTag(getFragmentTag( mViewPager.getId(), position)) == null) {
                    ChatFragment mCFragment = ChatFragment.newInstance(0, "Page # 3");
                    mCFragment.setRetainInstance(true);
                    return mCFragment;
                }else{
                    return mContext.getSupportFragmentManager().findFragmentByTag(getFragmentTag(mViewPager.getId(), position));
                }
            default:
                return null;
        }
    }

    @Override
    public int getCount() {
        return COUNT;
    }

    private String getFragmentTag(int viewPagerId, int fragmentPosition)
    {
        return "android:switcher:" + viewPagerId + ":" + fragmentPosition;
    }
}