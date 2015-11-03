package com.example.tomas.wisrandroid.Activities;

import android.content.DialogInterface;
import android.content.Intent;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Matrix;
import android.media.ExifInterface;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.provider.MediaStore;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.view.KeyEvent;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;

import com.example.tomas.wisrandroid.Helpers.ActivityLayoutHelper;
import com.example.tomas.wisrandroid.Helpers.CustomQuestionAdapter;
import com.example.tomas.wisrandroid.Helpers.CustomResponseOptionAdapter;
import com.example.tomas.wisrandroid.Model.ResponseOption;
import com.example.tomas.wisrandroid.R;

import java.io.File;
import java.util.ArrayList;

public class CreateQuestionActivity extends AppCompatActivity {

    private ImageView mImageView;
    private EditText mResponseEditText;
    private ListView mListView;
    private CustomResponseOptionAdapter mListViewAdapter;

    private ArrayList<ResponseOption> mResponseOptions = new ArrayList<ResponseOption>();
    protected static final int CAMERA_REQUEST = 0;
    protected static final int GALLERY_PICTURE = 1;
    private Intent pictureActionIntent = null;
    private Bitmap mBitmap;

    String selectedImagePath;

    @Override
    protected void onCreate( Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_create_question);
        //ActivityLayoutHelper.HideLayout(getWindow(), getSupportActionBar());
        if(getSupportActionBar() != null)
        {
            getSupportActionBar().hide();
        }

        mListView = (ListView) findViewById(R.id.create_question_responseoptions_listview);
        mListViewAdapter = new CustomResponseOptionAdapter(this,mResponseOptions);
        mListView.setAdapter(mListViewAdapter);

        mImageView = (ImageView) findViewById(R.id.createquestions_activity_imageview);
        mImageView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                startDialog();
            }
        });
        mResponseEditText = (EditText) findViewById(R.id.create_question_add_response_option_edittext);
        mResponseEditText.setOnEditorActionListener(new TextView.OnEditorActionListener() {
            @Override
            public boolean onEditorAction(TextView textView, int i, KeyEvent keyEvent) {
                if(keyEvent.getKeyCode() == KeyEvent.KEYCODE_ENTER)
                {
                    mResponseOptions.add(new ResponseOption(textView.getText().toString(), 0));
                    textView.clearComposingText();
                    mListViewAdapter.notifyDataSetChanged();
                    ViewGroup.LayoutParams mView = mListView.getLayoutParams();
                    View childView = mListViewAdapter.getView(0, null, mListView);
                    int height = childView.getHeight();
                    mView.height = height * mResponseOptions.size();
                    mListView.setLayoutParams(mView);
                    mListView.requestLayout();
                    return true;

                }
                return false;

            }
        });


    }

    @Override
    protected void onStart() {
        super.onStart();
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_create_room, menu);
        return true;
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

    // Kode luret fra http://stackoverflow.com/questions/11732872/android-how-can-i-call-camera-or-gallery-intent-together
    private void startDialog() {
        final AlertDialog.Builder myAlertDialogBuilder = new AlertDialog.Builder(this);
        myAlertDialogBuilder.setTitle("Image Options");
        myAlertDialogBuilder.setMessage("How do you want to select question image?");

        myAlertDialogBuilder.setPositiveButton("Gallery",
                new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialogInterface, int i) {
                        Intent pictureActionIntent = null;

                        pictureActionIntent = new Intent(Intent.ACTION_PICK, android.provider.MediaStore.Images.Media.EXTERNAL_CONTENT_URI);

                        startActivityForResult(pictureActionIntent, GALLERY_PICTURE);

                    }
                });

        myAlertDialogBuilder.setNegativeButton("Camera",
                new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialogInterface, int i) {

                        Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
                        File f = new File(android.os.Environment.getExternalStorageDirectory(), "temp.jpg");
                        intent.putExtra(MediaStore.EXTRA_OUTPUT, Uri.fromFile(f));

                        startActivityForResult(intent, CAMERA_REQUEST);

                    }
                });

        myAlertDialogBuilder.setNeutralButton("Cancel",
                new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialogInterface, int i) {
                        ((AlertDialog) dialogInterface).hide();
                    }
                });
        myAlertDialogBuilder.show();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {

        super.onActivityResult(requestCode, resultCode, data);

        mBitmap = null;
        selectedImagePath = null;

        if (resultCode == RESULT_OK && requestCode == CAMERA_REQUEST) {

            File f = new File(Environment.getExternalStorageDirectory()
                    .toString());
            for (File temp : f.listFiles()) {
                if (temp.getName().equals("temp.jpg")) {
                    f = temp;
                    break;
                }
            }

            if (!f.exists()) {

                Toast.makeText(getBaseContext(),

                        "Error while capturing image", Toast.LENGTH_LONG)

                        .show();

                return;

            }

            try {

                mBitmap = BitmapFactory.decodeFile(f.getAbsolutePath());

                mBitmap = Bitmap.createScaledBitmap(mBitmap, 400, 400, true);

                int rotate = 0;
                try {
                    ExifInterface exif = new ExifInterface(f.getAbsolutePath());
                    int orientation = exif.getAttributeInt(
                            ExifInterface.TAG_ORIENTATION,
                            ExifInterface.ORIENTATION_NORMAL);

                    switch (orientation) {
                        case ExifInterface.ORIENTATION_ROTATE_270:
                            rotate = 270;
                            break;
                        case ExifInterface.ORIENTATION_ROTATE_180:
                            rotate = 180;
                            break;
                        case ExifInterface.ORIENTATION_ROTATE_90:
                            rotate = 90;
                            break;
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
                Matrix matrix = new Matrix();
                matrix.postRotate(rotate);
                mBitmap = Bitmap.createBitmap(mBitmap, 0, 0, mBitmap.getWidth(),
                        mBitmap.getHeight(), matrix, true);



                mImageView.setImageBitmap(mBitmap);
                //storeImageTosdCard(bitmap);
            } catch (Exception e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }

        } else if (resultCode == RESULT_OK && requestCode == GALLERY_PICTURE) {
            if (data != null) {

                Uri selectedImage = data.getData();
                String[] filePath = { MediaStore.Images.Media.DATA };
                Cursor c = getContentResolver().query(selectedImage, filePath,
                        null, null, null);
                c.moveToFirst();
                int columnIndex = c.getColumnIndex(filePath[0]);
                selectedImagePath = c.getString(columnIndex);
                c.close();

                mBitmap = BitmapFactory.decodeFile(selectedImagePath); // load
                // preview image
                mBitmap = Bitmap.createScaledBitmap(mBitmap, 400, 400, false);

                mImageView.setImageBitmap(mBitmap);

            } else {
                Toast.makeText(getApplicationContext(), "Cancelled",
                        Toast.LENGTH_SHORT).show();
            }
        }

    }
}
