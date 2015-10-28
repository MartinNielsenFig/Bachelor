package com.example.tomas.wisrandroid.Activities;

import android.app.ActionBar;
import android.content.Intent;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ListView;
import android.widget.Toast;

import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.Volley;
import com.example.tomas.wisrandroid.Helpers.ActivityLayoutHelper;
import com.example.tomas.wisrandroid.Helpers.HttpHelper;
import com.example.tomas.wisrandroid.Helpers.CustomRoomAdapter;
import com.example.tomas.wisrandroid.Model.Room;
import com.example.tomas.wisrandroid.R;
import com.google.gson.Gson;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

public class SelectRoomActivity extends AppCompatActivity {

    private final ArrayList<Room> mRoomList = new ArrayList();
    private final Gson mGson = new Gson();
    private ListView mListView;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_select_room);
        //ActivityLayoutHelper.HideLayout(getWindow(), getSupportActionBar());

        if(getSupportActionBar() != null)
            getSupportActionBar().hide();

        mListView = (ListView) findViewById(R.id.select_room_listview);
        mListView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> adapterView, View view, int i, long l) {

                Gson mGson = new Gson();
                Bundle mBundle = new Bundle();
                mBundle.putString("Room", mGson.toJson((mRoomList.get(i))));
                Intent mIntent = new Intent(getApplicationContext(), RoomActivity.class);
                mIntent.putExtra("CurrentRoom",mBundle);
                startActivity(mIntent, mBundle);

            }
        });

        final Response.Listener<String> mListener = new Response.Listener<String>() {
            @Override
            public void onResponse(String response) {
                Toast.makeText(getApplicationContext(), "In Listener", Toast.LENGTH_LONG).show();

                Room[] mRooms = mGson.fromJson(response, Room[].class);
                for(Room room : mRooms)
                {
                    mRoomList.add(room);
                }
                CustomRoomAdapter temp = (CustomRoomAdapter)mListView.getAdapter();
                temp.notifyDataSetChanged();
            }
        };

        final CustomRoomAdapter mAdapter = new CustomRoomAdapter(this, mRoomList);
        mListView.setAdapter(mAdapter);

        Response.ErrorListener mErrorListener = new Response.ErrorListener() {
            @Override
            public void onErrorResponse(VolleyError volleyError) {
                Toast.makeText(getApplicationContext(), "In ErrorListener" + volleyError.getMessage(), Toast.LENGTH_LONG).show();
            }
        };

        Map<String, String> mmap= new HashMap<String,String>();

        RequestQueue requestQueue = Volley.newRequestQueue(SelectRoomActivity.this);

        HttpHelper jsObjRequest = new HttpHelper(getString(R.string.restapi_url) +"/Room/GetAll", mmap, mListener , mErrorListener);

        try {
            requestQueue.add(jsObjRequest);
        }
        catch (Exception e){

        }
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_select_room, menu);
        return true;
    }

    @Override
    protected void onStart() {
        super.onStart();
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
}
