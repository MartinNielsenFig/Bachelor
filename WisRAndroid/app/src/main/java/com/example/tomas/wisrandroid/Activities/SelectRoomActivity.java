package com.example.tomas.wisrandroid.Activities;

import android.support.v7.app.ActionBarActivity;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import android.widget.Toast;

import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.StringRequest;
import com.android.volley.toolbox.Volley;
import com.example.tomas.wisrandroid.Helpers.ActivityLayoutHelper;
import com.example.tomas.wisrandroid.Helpers.HttpHelper;
import com.example.tomas.wisrandroid.Helpers.CustomRoomAdapter;
import com.example.tomas.wisrandroid.Model.MyUser;
import com.example.tomas.wisrandroid.Model.Room;
import com.example.tomas.wisrandroid.R;
import com.google.gson.Gson;

import java.net.Proxy;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class SelectRoomActivity extends AppCompatActivity {

    final ArrayList<Room> mRoomList = new ArrayList();
    ListView mListView;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_select_room);
        ActivityLayoutHelper.HideLayout(getWindow(), getSupportActionBar());

        mListView = (ListView) findViewById(R.id.select_room_listview);

        final Response.Listener<String> mListener = new Response.Listener<String>() {
            @Override
            public void onResponse(String response) {
                Toast.makeText(getApplicationContext(), "In Listener", Toast.LENGTH_LONG).show();

                Gson mGson = new Gson();
                Room[] mRooms = mGson.fromJson(response, Room[].class);
                for(Room room : mRooms)
                {
                    mRoomList.add(room);
                }
                Integer mInt = mListView.getAdapter().getCount();
                // String mresponsee = response;
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

        HttpHelper jsObjRequest = new HttpHelper("http://wisrrestapi.aceipse.dk/Room/GetAll", mmap, mListener , mErrorListener);

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
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.action_settings) {
            return true;
        }

        return super.onOptionsItemSelected(item);
    }
}
