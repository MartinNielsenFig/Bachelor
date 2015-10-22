package com.example.tomas.wisrandroid.Fragments;

import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ListView;
import android.widget.Toast;

import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.Volley;
import com.example.tomas.wisrandroid.Activities.RoomActivity;
import com.example.tomas.wisrandroid.Helpers.CustomQuestionAdapter;
import com.example.tomas.wisrandroid.Helpers.HttpHelper;
import com.example.tomas.wisrandroid.Model.MultipleChoiceQuestion;
import com.example.tomas.wisrandroid.Model.Question;
import com.example.tomas.wisrandroid.Model.TextualQuestion;
import com.example.tomas.wisrandroid.R;
import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonParser;

import java.util.ArrayList;


// https://github.com/codepath/android_guides/wiki/ViewPager-with-FragmentPagerAdapter
public class QuestionListFragment extends android.support.v4.app.Fragment {
    private String title;
    private int page;
    private String roomId;
    private final Gson gson = new Gson();
    private ListView mListView;
    private CustomQuestionAdapter mAdapter;
    private final ArrayList<Question> mQuestions = new ArrayList<Question>();


    public static QuestionListFragment newInstance(int page, String title, String roomId) {
        QuestionListFragment questionListFragment = new QuestionListFragment();
        Bundle args = new Bundle();
        args.putInt("someInt", page);
        args.putString("someTitle", title);
        args.putString("someRoomId",roomId);
        questionListFragment.setArguments(args);

        return questionListFragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        page = getArguments().getInt("someInt", 0);
        title = getArguments().getString("someTitle");
        roomId = getArguments().getString("someRoomId");

        InitQuestionList();
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_question_list, container, false);

        Log.w("QuestionListFragment","View Created");
        mAdapter = new CustomQuestionAdapter(getContext(), mQuestions);
        mListView = (ListView)view.findViewById(R.id.question_listview);
        mListView.setAdapter(mAdapter);
        mListView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> adapterView, View view, int i, long l) {
                setCurrentQuestionFragment(mQuestions.get(i));
            }
        });
        return view;
    }

    @Override
    public void onStart() {
        super.onStart();

    }

    @Override
    public void onResume() {
        super.onResume();

    }

    public void setCurrentQuestionFragment(Question curQuestion)
    {
        ((RoomActivity)getActivity()).TransferCurrentQuestion(curQuestion);
    }

    private void InitQuestionList()
    {
        Response.Listener<String> mListener = new Response.Listener<String>() {
            @Override
            public void onResponse(String response) {

                JsonElement e = new JsonParser().parse(response);
                JsonArray array = e.getAsJsonArray();
                for (JsonElement element : array) {
                    if(element.toString().contains("MultipleChoiceQuestion")){
                        mQuestions.add(gson.fromJson(element,MultipleChoiceQuestion.class));
                    }else
                    {
                        mQuestions.add(gson.fromJson(element, TextualQuestion.class));
                    }
                }
                mAdapter.notifyDataSetChanged();
            }
        };

        Response.ErrorListener mErrorListener = new Response.ErrorListener() {
            @Override
            public void onErrorResponse(VolleyError volleyError) {
                Toast.makeText(getContext(),String.valueOf(volleyError.networkResponse.statusCode),Toast.LENGTH_LONG).show();
            }
        };

        RequestQueue requestQueue = Volley.newRequestQueue(getContext());
        HttpHelper jsObjRequest = new HttpHelper( getString(R.string.restapi_url) + "/Question/GetQuestionsForRoomWithoutImages?roomId="+ roomId, null, mListener, mErrorListener);

        try {
            requestQueue.add(jsObjRequest);
        } catch (Exception e) {

        }
    }
}