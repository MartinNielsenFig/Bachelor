package com.example.tomas.wisrandroid.Fragments;

import android.app.Activity;
import android.net.Uri;
import android.os.Bundle;
import android.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.example.tomas.wisrandroid.R;


// https://github.com/codepath/android_guides/wiki/ViewPager-with-FragmentPagerAdapter
public class QuestionListFragment extends android.support.v4.app.Fragment {
    private String title;
    private int page;

    public static QuestionListFragment newInstance(int page, String title) {
        QuestionListFragment questionListFragment = new QuestionListFragment();
        Bundle args = new Bundle();
        args.putInt("someInt", page);
        args.putString("someTitle", title);
        questionListFragment.setArguments(args);

        return questionListFragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        page = getArguments().getInt("someInt", 0);
        title = getArguments().getString("someTitle");
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {

        View view = inflater.inflate(R.layout.fragment_question_list, container, false);
        Bundle args = getArguments();
        TextView mTextView = (TextView) view.findViewById(R.id.fragment_textview);
        mTextView.setText(page + " __ " + title);
        return view;
    }
}