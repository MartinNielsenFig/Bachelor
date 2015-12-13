package com.example.tomas.wisrandroid.Fragments;

import android.content.Intent;
import android.os.Bundle;
import android.support.v4.widget.PopupWindowCompat;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.ListView;
import android.widget.PopupWindow;
import android.widget.TextView;
import android.widget.Toast;

import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.Volley;
import com.example.tomas.wisrandroid.Activities.CreateQuestionActivity;
import com.example.tomas.wisrandroid.Activities.RoomActivity;
import com.example.tomas.wisrandroid.Helpers.CustomQuestionAdapter;
import com.example.tomas.wisrandroid.Helpers.ErrorCodesDeserializer;
import com.example.tomas.wisrandroid.Helpers.ErrorTypesDeserializer;
import com.example.tomas.wisrandroid.Helpers.HttpHelper;
import com.example.tomas.wisrandroid.Model.ErrorCodes;
import com.example.tomas.wisrandroid.Model.ErrorTypes;
import com.example.tomas.wisrandroid.Model.MultipleChoiceQuestion;
import com.example.tomas.wisrandroid.Model.MyUser;
import com.example.tomas.wisrandroid.Model.Notification;
import com.example.tomas.wisrandroid.Model.Question;
import com.example.tomas.wisrandroid.Model.Room;
import com.example.tomas.wisrandroid.Model.TextualQuestion;
import com.example.tomas.wisrandroid.Model.Vote;
import com.example.tomas.wisrandroid.R;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonParser;

import java.lang.reflect.Array;
import java.util.ArrayList;


// https://github.com/codepath/android_guides/wiki/ViewPager-with-FragmentPagerAdapter
public class QuestionListFragment extends android.support.v4.app.Fragment {
    private String title;
    private int page;
    private Room mRoom;
    private Gson gson;
    private ListView mListView;
    private TextView mTextView;
    private Button mButton;
    private CustomQuestionAdapter mAdapter;
    private ArrayList<Question> mQuestions = new ArrayList<Question>();


    public static QuestionListFragment newInstance(int page, String title, Room room) {
        QuestionListFragment questionListFragment = new QuestionListFragment();
        Bundle args = new Bundle();
        Gson tempGson = new Gson();
        args.putInt("someInt", page);
        args.putString("someTitle", title);
        args.putString("someRoom",tempGson.toJson(room));
        questionListFragment.setArguments(args);

        return questionListFragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        GsonBuilder mGsonBuilder = new GsonBuilder();
        mGsonBuilder.registerTypeAdapter(ErrorTypes.class,new ErrorTypesDeserializer());
        mGsonBuilder.registerTypeAdapter(ErrorCodes.class,new ErrorCodesDeserializer());
        gson = mGsonBuilder.create();

        page = getArguments().getInt("someInt", 0);
        title = getArguments().getString("someTitle");
        mRoom = gson.fromJson(getArguments().getString("someRoom"),Room.class);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_question_list, container, false);

        Log.w("QuestionListFragment","View Created");
        mTextView = (TextView) view.findViewById(R.id.questionlistfragment_textview);
        mButton = (Button) view.findViewById(R.id.ask_question_button);
        mButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if(MyUser.getMyuser().get_Id() != null)
                {
                    Intent mIntent = new Intent(getActivity(), CreateQuestionActivity.class);
                    Bundle mBundle = new Bundle();
                    mBundle.putString("RoomId",mRoom.get_id());
                    mIntent.putExtra("Bundle", mBundle);
                    getActivity().startActivity(mIntent);
                } else {
                    Toast.makeText(getContext(),"You have to log in to ask questions",Toast.LENGTH_LONG).show();
                }

            }
        });
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
    public void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);

    }

    @Override
    public void onStart() {
        super.onStart();

    }

    @Override
    public void onResume() {
        super.onResume();
        InitQuestionList();
        mTextView.setText(mRoom.get_Name() + " questions:");

    }

    public void setCurrentQuestionFragment(Question curQuestion)
    {
        ((RoomActivity)getActivity()).TransferCurrentQuestion(curQuestion);
    }

    public void InitQuestionList()
    {
        mQuestions.clear();
        Response.Listener<String> mListener = new Response.Listener<String>() {
            @Override
            public void onResponse(String response) {

                Notification mNotification = gson.fromJson(response, Notification.class);

                if(mNotification.get_ErrorType() == ErrorTypes.Ok || mNotification.get_ErrorType() == ErrorTypes.Complicated) {
                    ArrayList<Question> mTempQuestions = new ArrayList<>();
                    JsonElement e = new JsonParser().parse(mNotification.get_Data());
                    JsonArray array = e.getAsJsonArray();
                    for (JsonElement element : array) {
                        if (element.toString().contains("MultipleChoiceQuestion")) {
                            mTempQuestions.add(gson.fromJson(element, MultipleChoiceQuestion.class));
                        } else {
                            mTempQuestions.add(gson.fromJson(element, TextualQuestion.class));
                        }
                    }
                    RearrangeQuestions(mTempQuestions);
                    mAdapter.notifyDataSetChanged();
                }
            }
        };

        Response.ErrorListener mErrorListener = new Response.ErrorListener() {
            @Override
            public void onErrorResponse(VolleyError volleyError) {
                //Toast.makeText(getContext(),String.valueOf(volleyError.networkResponse.statusCode),Toast.LENGTH_LONG).show();
            }
        };

        RequestQueue requestQueue = Volley.newRequestQueue(getContext());
        HttpHelper jsObjRequest = new HttpHelper( getString(R.string.restapi_url) + "/Question/GetQuestionsForRoomWithoutImages?roomId="+ mRoom.get_id(), null, mListener, mErrorListener);

        try {
            requestQueue.add(jsObjRequest);
        } catch (Exception e) {

        }
    }

    private int CalculateVotes(ArrayList<Vote> votes)
    {
        int voteValue = 0;
        for (Vote vote : votes) {
            voteValue += vote.get_value();
        }
        return voteValue;
    }

    private void RearrangeQuestions(ArrayList<Question> mTempList)
    {

        for (Question question : mTempList) {
            if (question.get_CreatedById() != null) {

                if (question.get_CreatedById().equals(mRoom.get_CreatedById())) {
                    mQuestions.add(0, question);
                } else {
                    int index = 0;
                    while (true) {
                        if (index == mQuestions.size()) {
                            mQuestions.add(index, question);
                            break;
                        }
                        if (!mQuestions.isEmpty() || (CalculateVotes(question.get_Votes()) > CalculateVotes(mQuestions.get(index).get_Votes()) && !question.get_CreatedById().equals(mRoom.get_CreatedById()))) {
                            mQuestions.add(index, question);
                            break;
                        }
                        index++;
                    }
                }
            }
        }
    }
}