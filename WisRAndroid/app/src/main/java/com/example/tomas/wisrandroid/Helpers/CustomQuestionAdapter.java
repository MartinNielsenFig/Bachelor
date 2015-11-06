package com.example.tomas.wisrandroid.Helpers;


import android.content.Context;
import android.graphics.BitmapFactory;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.util.Base64;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.example.tomas.wisrandroid.Model.Question;
import com.example.tomas.wisrandroid.Model.Vote;
import com.example.tomas.wisrandroid.R;

import java.util.ArrayList;

public class CustomQuestionAdapter extends ArrayAdapter<Question> {

    private final Context context;
    private final ArrayList<Question> values;

    public CustomQuestionAdapter(Context context, ArrayList<Question> values) {
        super(context, -1, values);
        this.context = context;
        this.values = values;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        LayoutInflater inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
        View rowView = inflater.inflate(R.layout.questionrowlayout, parent, false);
        TextView mQuestionTextTextView = (TextView) rowView.findViewById(R.id.question_row_textview);
        mQuestionTextTextView.setText(values.get(position).get_QuestionText());
        TextView mQuestionUpVotesTextView = (TextView) rowView.findViewById(R.id.question_row_thumbs_up_textview);
        mQuestionUpVotesTextView.setText(CalculateVotes(values.get(position).get_Votes(), true));
        TextView mQuestionDownVotesTextView = (TextView) rowView.findViewById(R.id.question_row_thumbs_down_textview);
        mQuestionDownVotesTextView.setText(CalculateVotes(values.get(position).get_Votes(),false));

        return rowView;
    }

    private String CalculateVotes(ArrayList<Vote> votes, boolean voteType)
    {
        if(voteType) {
            int upvotes = 0;
            for (Vote vote : votes) {
                if (vote.get_value() == 1)
                    upvotes++;
            }
            return String.valueOf(upvotes);
        } else {
            int downvotes = 0;
            for (Vote vote : votes) {
                if (vote.get_value() == -1)
                    downvotes++;
            }
            return String.valueOf(downvotes);
        }
    }
}
