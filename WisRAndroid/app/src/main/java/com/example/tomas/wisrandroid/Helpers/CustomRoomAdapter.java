package com.example.tomas.wisrandroid.Helpers;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.TextView;
import com.example.tomas.wisrandroid.Model.Room;
import com.example.tomas.wisrandroid.R;

import java.util.ArrayList;

public class CustomRoomAdapter extends ArrayAdapter<Room> {

    private final Context context;
    private final ArrayList<Room> values;

    public CustomRoomAdapter(Context context, ArrayList<Room> values) {
        super(context, -1, values);
        this.context = context;
        this.values = values;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        LayoutInflater inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
        View rowView = inflater.inflate(R.layout.roomrowlayout, parent, false);
        TextView textView = (TextView) rowView.findViewById(R.id.custom_name);
        TextView textView2 = (TextView) rowView.findViewById(R.id.custom_tag);
        TextView textView3 = (TextView) rowView.findViewById(R.id.custom_anonymous);
        TextView textView4 = (TextView) rowView.findViewById(R.id.custom_radius);
        textView.setText(values.get(position).get_Name());
        textView2.setText(values.get(position).get_Tag());
        textView3.setText(values.get(position).get_AllowAnonymous() ? "Anonymous: Yes" : "Anonymous: No");
        textView4.setText(String.valueOf(values.get(position).get_Radius()) + " meters");

        return rowView;
    }
}

