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
import com.example.tomas.wisrandroid.Model.ResponseOption;
import com.example.tomas.wisrandroid.R;

import java.util.ArrayList;

public class CustomResponseOptionAdapter extends ArrayAdapter<ResponseOption> {

    private final Context context;
    private final ArrayList<ResponseOption> values;

    public CustomResponseOptionAdapter(Context context, ArrayList<ResponseOption> values) {
        super(context, -1, values);
        this.context = context;
        this.values = values;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        LayoutInflater inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
        View rowView = inflater.inflate(R.layout.responseoptionrowlayout, parent, false);
        TextView textView = (TextView) rowView.findViewById(R.id.response_row_textview);
        textView.setText(values.get(position).get_value());

        return rowView;
    }
}
