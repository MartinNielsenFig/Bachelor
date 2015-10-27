package com.example.tomas.wisrandroid.Activities;

import android.os.Bundle;
import android.os.PersistableBundle;
import android.support.v4.view.ViewPager;
import android.support.v7.app.ActionBar;
import android.support.v7.app.AppCompatActivity;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.WindowManager;
import android.widget.Toast;


import com.example.tomas.wisrandroid.Fragments.SelectedQuestionFragment;
import com.example.tomas.wisrandroid.Helpers.CustomPagerAdapter;
import com.example.tomas.wisrandroid.Model.Question;
import com.example.tomas.wisrandroid.Model.Room;
import com.example.tomas.wisrandroid.R;
import com.google.gson.Gson;

public class RoomActivity extends AppCompatActivity {

    private CustomPagerAdapter mPagerAdapter;
    private ViewPager mViewPager;
    private Room mRoom;
    private final Gson gson = new Gson();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_room);
        HideUI();
        if (savedInstanceState == null)
        {
            // Getting Room From Intent
            String roomString = getIntent().getBundleExtra("CurrentRoom").getString("Room");
            mRoom = gson.fromJson(roomString, Room.class);
        } else {
            String roomString = savedInstanceState.getString("Room");
            mRoom = gson.fromJson(roomString, Room.class);
        }

        // Setting up the viewpager for RoomActivity
        mViewPager = (ViewPager) findViewById(R.id.pager);
        mViewPager.setOffscreenPageLimit(3);
        mPagerAdapter = new CustomPagerAdapter(this,getSupportFragmentManager(), mRoom,mViewPager);
        mViewPager.setAdapter(mPagerAdapter);
        mViewPager.setOnPageChangeListener(new ViewPager.OnPageChangeListener() {
            @Override
            public void onPageScrolled(int position, float positionOffset, int positionOffsetPixels) {

            }

            @Override
            public void onPageSelected(int position) {
                if (position == 0) {
                    ((SelectedQuestionFragment)mPagerAdapter.getItem(1)).ClearImage();
                    Toast.makeText(RoomActivity.this, "Questions", Toast.LENGTH_SHORT).show();
                } else if (position == 1) {
                    ((SelectedQuestionFragment)mPagerAdapter.getItem(1)).initView();
                    Toast.makeText(RoomActivity.this, "Selected Question", Toast.LENGTH_SHORT).show();
                } else {
                    Toast.makeText(RoomActivity.this, "Chat", Toast.LENGTH_SHORT).show();
                }

                mViewPager.setCurrentItem(position);
            }

            @Override
            public void onPageScrollStateChanged(int state) {

            }
        });

    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_room, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.action_settings) {
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

    @Override
    protected void onPause() {
        super.onPause();
    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();

        //Intent mIntent = new Intent(this,SelectRoomActivity.class);
        //startActivity(mIntent);
    }

    @Override
    public void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
        outState.putString("Room",gson.toJson(mRoom));
    }

    public void HideUI() {
        //getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
        //getWindow().getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN);
        ActionBar actionBar = getSupportActionBar();
        actionBar.hide();
    }

    public void Init() {

    }

    public void TransferCurrentQuestion(Question curQuestion)
    {
        ((SelectedQuestionFragment)mPagerAdapter.getItem(1)).setCurrentQuestion(curQuestion);
        mViewPager.setCurrentItem(1);
    }

}


