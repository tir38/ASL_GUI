If you reach an error `"Undefined function 'testSift'` then you need to find all occurances of this method and uncomment the `mlpfwd` method instead:

```
[mPrediction,~]=testSift(trainingSet,predictImage); // replace this ...
mPrediction = mlpfwd(mNet,mFrame); // ... with this
```

This is the result of an incomplete refactor.

===========================================================================
24-787 Project: American Sign Language (ASL) Recognition System
===========================================================================

The purpose of this document is to provide useful instructions and details 
pertaining to the MATLAB code developed for this project.

%%%%% ACQUIRING TRAINING DATA %%%%%
To get training data for the neural network, follow these steps:

    % Load the GUI
    >>aslgui

    % Set the directory in which to store the training samples
    % (default is '/training data' subfolder of current directory)

    % Set the desired filename prefix. For now, I propose to
    % use the initials of the subject. Currently, the filename convention
    % is fixed to PRE###.mat where PRE is the prefix and ### increments for
    % each sample.

    % Turn the camera on by pressing the START CAMERA button.
    % The camera should begin streaming in the VIDEO STREAM panel.

    % Make sure that the desired class (letter sign) is selected in the 
    % PALETTE panel. The letter should appear below along with a
    % corresponding value (1-26 for A-Z).

    % When you are ready, press the CAPTURE FRAME button to save a single
    % frame of data. The frame is saved as a variable DATA in the selected
    % directory with the selected filename. DATA is a 307201x1 vector,
    % where the first 

To view a complete listing of video input functions and properties, use 
     >>imaqhelp videoinput

     Example:
        % Construct a video input object
        obj = videoinput('winvideo');
 
        % Select the source to use for acquisition. 
        set(obj, 'SelectedSourceName', 'input1')
 
        % View the properties for the selected video source object.
        src_obj = getselectedsource(obj);
        get(src_obj)
 
        % Preview a stream of image frames.
        preview(obj);
 
        % Acquire and display a single image frame.
        frame = getsnapshot(obj);
        image(frame);
 
        % Remove video input object from memory.
        delete(obj);

videoaq.m: acquire video via webcam and display in a GUI
    



Notes:


File list:
1. aslgui.m:  The main file containing a GUI for acquiring training data.
2. signPalette.m:  The file that contains the list of available signs (nested in aslgui.m).
