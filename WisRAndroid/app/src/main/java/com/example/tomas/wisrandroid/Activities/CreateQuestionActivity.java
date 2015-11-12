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
import android.util.Base64;
import android.view.KeyEvent;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;

import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.Volley;
import com.example.tomas.wisrandroid.Helpers.ActivityLayoutHelper;
import com.example.tomas.wisrandroid.Helpers.CustomQuestionAdapter;
import com.example.tomas.wisrandroid.Helpers.CustomResponseOptionAdapter;
import com.example.tomas.wisrandroid.Helpers.ErrorCodesDeserializer;
import com.example.tomas.wisrandroid.Helpers.ErrorTypesDeserializer;
import com.example.tomas.wisrandroid.Helpers.HttpHelper;
import com.example.tomas.wisrandroid.Model.Answer;
import com.example.tomas.wisrandroid.Model.ErrorCodes;
import com.example.tomas.wisrandroid.Model.ErrorTypes;
import com.example.tomas.wisrandroid.Model.MultipleChoiceQuestion;
import com.example.tomas.wisrandroid.Model.MyUser;
import com.example.tomas.wisrandroid.Model.Notification;
import com.example.tomas.wisrandroid.Model.Question;
import com.example.tomas.wisrandroid.Model.ResponseOption;
import com.example.tomas.wisrandroid.Model.Vote;
import com.example.tomas.wisrandroid.R;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

public class CreateQuestionActivity extends AppCompatActivity {

    private ImageView mImageView;
    private EditText mResponseEditText;
    private EditText mQuestionTextEditText;
    private ListView mListView;
    private CustomResponseOptionAdapter mListViewAdapter;
    private Button mCreateQuestionButton;

    private ArrayList<ResponseOption> mResponseOptions = new ArrayList<ResponseOption>();
    protected static final int CAMERA_REQUEST = 0;
    protected static final int GALLERY_PICTURE = 1;
    private Intent pictureActionIntent = null;
    private Bitmap mBitmap;
    private Gson gson;
    private String mRoomId;

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

        GsonBuilder mGsonBuilder = new GsonBuilder();
        mGsonBuilder.registerTypeAdapter(ErrorTypes.class,new ErrorTypesDeserializer());
        mGsonBuilder.registerTypeAdapter(ErrorCodes.class,new ErrorCodesDeserializer());
        gson = mGsonBuilder.create();

        final View activityRootView = findViewById(R.id.create_question_root);
        activityRootView.getViewTreeObserver().addOnGlobalLayoutListener(new ViewTreeObserver.OnGlobalLayoutListener() {
            @Override
            public void onGlobalLayout() {
                int heightDiff = activityRootView.getRootView().getHeight() - activityRootView.getHeight();
                if (heightDiff > 100) { // if more than 100 pixels, its probably a keyboard...
                    activityRootView.getLayoutParams().height += heightDiff;}
                else{ activityRootView.getLayoutParams().height += heightDiff;}
            }
        });

        mRoomId = getIntent().getBundleExtra("Bundle").getString("RoomId");

        mListView = (ListView) findViewById(R.id.create_question_responseoptions_listview);
        mListViewAdapter = new CustomResponseOptionAdapter(this,mResponseOptions);
        mListView.setAdapter(mListViewAdapter);

        mImageView = (ImageView) findViewById(R.id.createquestion_activity_imageview);
        mImageView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                startDialog();
            }
        });

        mResponseEditText = (EditText) findViewById(R.id.create_question_add_response_option_edittext);
        mResponseEditText.setOnKeyListener(new View.OnKeyListener() {
            @Override
            public boolean onKey(View view, int i, KeyEvent keyEvent) {
                if(keyEvent.getKeyCode() == KeyEvent.KEYCODE_ENTER && keyEvent.getAction() == keyEvent.ACTION_DOWN)
                {
                    mResponseOptions.add(new ResponseOption(((EditText)view).getText().toString(), 0));
                    ((EditText)view).setText("");

                    // Measuring the individual children of the listview
                    View childView = mListViewAdapter.getView(0, null, mListView);
                    childView.measure(View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED), View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED));
                    int height = childView.getMeasuredHeight();
                    int children = mResponseOptions.size();

                    // Calculating and setting height of the listview through the number of children
                    ViewGroup.LayoutParams mView = mListView.getLayoutParams();
                    mView.height = height*children;
                    mListView.setLayoutParams(mView);
                    mListView.requestLayout();
                    return true;

                }

                return false;
            }
        });

        mQuestionTextEditText = (EditText) findViewById(R.id.createquestion_activity_questiontext_edittext);

        mCreateQuestionButton = (Button) findViewById(R.id.create_question_button);
        mCreateQuestionButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                String imgString = "";
                if (mImageView.getDrawable() != null){
                    ByteArrayOutputStream mByteOutStream = new ByteArrayOutputStream();
                    mBitmap.compress(Bitmap.CompressFormat.JPEG,100,mByteOutStream);
                    byte[] b = mByteOutStream.toByteArray();
                    imgString = Base64.encodeToString(b, Base64.DEFAULT);
                }

                if (mQuestionTextEditText.getText() != null && !mQuestionTextEditText.getText().toString().equals("") && !mResponseOptions.isEmpty()) {

                    Question mQuestion = new MultipleChoiceQuestion();
                    mQuestion.set_CreatedById(MyUser.getMyuser().get_Id());
                    mQuestion.setCreatedByUserDisplayName(MyUser.getMyuser().get_DisplayName());
                    mQuestion.set_QuestionText(mQuestionTextEditText.getText().toString());
                    mQuestion.set_Img(imgString);
                    mQuestion.set_ResponseOptions(mResponseOptions);
                    mQuestion.set_RoomId(mRoomId);
                    mQuestion.set_Votes(new ArrayList<Vote>());
                    mQuestion.set_Result(new ArrayList<Answer>());

                    Map<String, String> mParams = new HashMap<String, String>();
                    mParams.put("question", gson.toJson(mQuestion));
                    String [] mType = mQuestion.getClass().toString().split("\\.");
                    mParams.put("type", mType[mType.length-1]);

                    Response.Listener<String> mListener = new Response.Listener<String>() {
                        @Override
                        public void onResponse(String response) {

                            Notification mNotification = gson.fromJson(response, Notification.class);

                            if (mNotification.get_ErrorType() == ErrorTypes.Ok || mNotification.get_ErrorType() == ErrorTypes.Complicated) {
                                Toast.makeText(getApplicationContext(), "Question Created", Toast.LENGTH_LONG).show();
                            } else {
                                Toast.makeText(getApplicationContext(), "Failed to create question", Toast.LENGTH_LONG).show();
                            }
                        }
                    };

                    Response.ErrorListener mErrorListener = new Response.ErrorListener() {
                        @Override
                        public void onErrorResponse(VolleyError volleyError) {
                            Toast.makeText(getApplicationContext(), String.valueOf(volleyError.networkResponse.statusCode), Toast.LENGTH_LONG).show();
                        }
                    };

                    RequestQueue requestQueue = Volley.newRequestQueue(getApplicationContext());
                    HttpHelper jsObjRequest = new HttpHelper(Request.Method.POST, getString(R.string.restapi_url) + "/Question/CreateQuestion", mParams, mListener, mErrorListener);

                    try {
                        requestQueue.add(jsObjRequest);
                    } catch (Exception e) {

                    }
                } else {
                    final AlertDialog.Builder myAlertDialogBuilder = new AlertDialog.Builder(view.getContext());
                    myAlertDialogBuilder.setTitle("Warning");
                    myAlertDialogBuilder.setMessage("You have to enter question text and atleast one response option to create a question!");
                    myAlertDialogBuilder.setCancelable(false);
                    myAlertDialogBuilder.setPositiveButton("Ok", new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialogInterface, int i) {
                            dialogInterface.dismiss();
                        }
                    });
                    myAlertDialogBuilder.show();
                }
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
        myAlertDialogBuilder.setCancelable(false);

        myAlertDialogBuilder.setPositiveButton("Gallery", new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialogInterface, int i) {
                        Intent pictureActionIntent = null;
                        pictureActionIntent = new Intent(Intent.ACTION_PICK, android.provider.MediaStore.Images.Media.EXTERNAL_CONTENT_URI);

                        startActivityForResult(pictureActionIntent, GALLERY_PICTURE);

                    }
                });

        myAlertDialogBuilder.setNegativeButton("Camera", new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialogInterface, int i) {

                        Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
                        File f = new File(android.os.Environment.getExternalStorageDirectory(), "temp.jpg");
                        intent.putExtra(MediaStore.EXTRA_OUTPUT, Uri.fromFile(f));

                        startActivityForResult(intent, CAMERA_REQUEST);

                    }
                });

        myAlertDialogBuilder.setNeutralButton("Cancel", new DialogInterface.OnClickListener() {
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

            File f = new File(Environment.getExternalStorageDirectory().toString());
            for (File temp : f.listFiles()) {
                if (temp.getName().equals("temp.jpg")) {
                    f = temp;
                    break;
                }
            }

            if (!f.exists()) {
                Toast.makeText(getBaseContext(),"Error while capturing image", Toast.LENGTH_LONG).show();
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
                mBitmap = Bitmap.createBitmap(mBitmap, 0, 0, mBitmap.getWidth(),mBitmap.getHeight(), matrix, true);

                mImageView.setImageBitmap(mBitmap);
            } catch (Exception e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }

        } else if (resultCode == RESULT_OK && requestCode == GALLERY_PICTURE) {
            if (data != null) {

                Uri selectedImage = data.getData();
                String[] filePath = { MediaStore.Images.Media.DATA };
                Cursor c = getContentResolver().query(selectedImage, filePath, null, null, null);
                c.moveToFirst();
                int columnIndex = c.getColumnIndex(filePath[0]);
                selectedImagePath = c.getString(columnIndex);
                c.close();

                mBitmap = BitmapFactory.decodeFile(selectedImagePath); // load
                // preview image
                mBitmap = Bitmap.createScaledBitmap(mBitmap, 400, 400, false);

                mImageView.setImageBitmap(mBitmap);

            } else {
                Toast.makeText(getApplicationContext(), "Cancelled", Toast.LENGTH_SHORT).show();
            }
        }

    }
}
