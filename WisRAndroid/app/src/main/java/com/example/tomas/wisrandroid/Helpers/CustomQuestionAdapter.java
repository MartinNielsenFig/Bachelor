package com.example.tomas.wisrandroid.Helpers;


import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.TextView;

import com.example.tomas.wisrandroid.Model.Question;
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
        View rowView = inflater.inflate(R.layout.roomrowlayout, parent, false);
        TextView textView = (TextView) rowView.findViewById(R.id.question_row_textview);

        //Room s = values.get(position);

        return rowView;
    }
}
