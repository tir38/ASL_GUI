function varargout = signPalette(varargin)
% SIGNPALETTE GUI used as a child in ASLR GUIs.
%       SIGNPALETTE populates a sign palette into a given figure or panel 
%       provided as an input parameter through custom property 'parent'. 
%       If user does not provide parent, GCF will be used.
%
%       GETSIGNFCN = SIGNPALETTE(...) runs the GUI. And return a function
%       handle for getting the currently selected sign in the sign palette.
%       The returned function handle can be used at any time before the
%       sign palette is destroyed.
%
%       SIGNPALETTE('Property','Value',...) runs the GUI. This GUI accepts
%       property value pairs from the input arguments. Only the following
%       custom properties are supported that can be used to initialize this
%       GUI. The names are not case sensitive:  
%         'parent'  the parent figure or panel that holds the sign palette
%       Other unrecognized property names or invalid values are ignored.
%
%   Created 4/9/12 MRE
%   Last Updated 4/9/12 MRE

% Declare non-UI data so that they can be used in any functions in this GUI
% file, including functions triggered by creating the GUI layout below
mInputArgs = varargin;  % Command line arguments when invoking the GUI
mOutputArgs = {};       % Variable for storing output when GUI returns
mSelectedSign = 0;      % Currently selected sign in the palette
% Variables for supporting custom property/value pairs
mPropertyDefs = {...    % The supported custom property/value pairs of this GUI
                 'parent',@localValidateInput,'mPaletteParent'};
mPaletteParent = [];    % Use input property 'parent' to initialize

% Process the comman line input arguments supplied when the GUI is invoked
processUserInputs();

% Declare and create all the UI objects used in this GUI
hPalettePanel       = uibuttongroup('Parent',mPaletteParent,...
                            'Units','normalized',...
                            'Position',[0 0 1 1],...
                            'Title',{''},...
                            'BorderType','none',...
                            'SelectionChangeFcn',@hPalettePanelSelectionChanged);
hSelectedSignText   = uicontrol('Parent',hPalettePanel,...
                            'Units', 'normalized',...
                            'Style', 'text',...
                            'FontSize',42,...
                            'ForegroundColor',[1 0 0]); 
hSignValueText      = uicontrol('Parent',hPalettePanel,...
                            'Units', 'normalized',...
                            'Style', 'text',...
                            'FontSize',18,...
                            'ForegroundColor',[0 0 1],...
                            'HorizontalAlignment', 'left'); 
hMoreSignsButton    = uicontrol('Parent',hPalettePanel,...
                            'Units', 'normalized',...
                            'String', 'More Signs ...',...
                            'Callback',@hMoreSignsButtonCallback);
                        
% Dynamically create the sign cells and palette tools and layout component
layoutComponent();

% Initialize the displayed color information
localUpdateSign();

% Return user-defined output if it is requested
mOutputArgs{1} = @getSelectedSign;
if nargout>0
    [varargout{1:nargout}] = mOutputArgs{:};
end

    %----------------------------------------------------------------------
    function sgn = getSelectedSign
    % function returns the currently selected sign in the signPlatte
        sgn = double(mSelectedSign-64)*(double(mSelectedSign-64)>0);
    end

    %----------------------------------------------------------------------
    function hPalettePanelSelectionChanged(hObject, eventdata)
    % Callback called when the selected sign is changed in the signPlatte
        selected = get(hPalettePanel,'SelectedObject');
        def = get(selected, 'UserData');
        if ~isempty(def) && isfield(def,'Callback')
            def.Callback(selected, eventdata);
        end
    end

    %----------------------------------------------------------------------
    function hMoreSignsButtonCallback(hObject, eventdata)
    % Callback called when the more signs button is pressed. 
        str = sprintf('There are currently no other available signs.'); disp(str);
%         sgn = mSelectedSign;
%         if isnan(sgn)
%             sgn =[0 0 0];
%         end
%         sgn = uisetsgn(sgn);
%         if ~isequal(sgn, mSelectedSign)
%             mSelectedSign = sgn;
%             localUpdateSign();
%         end
    end

    %----------------------------------------------------------------------
    function eraserToolCallback(hObject, eventdata)
    % Callback called when the eraser palette tool button is pressed
        mSelectedSign = 0;
        localUpdateSign();
    end

    %----------------------------------------------------------------------
    function signCellCallback(hObject, eventdata)
    % Callback called when any sign cell button is pressed
        mSelectedSign = get(hObject, 'String');
        localUpdateSign();
    end

    %----------------------------------------------------------------------
    function localUpdateSign
    % helper function that updates the preview of the selected sign
        set(hSelectedSignText, 'String', mSelectedSign);
        set(hSignValueText, 'String',['Value: ' num2str(double(mSelectedSign-64)*(double(mSelectedSign-64)>0))]);
    end

    %----------------------------------------------------------------------
    function layoutComponent
    % helper function that dynamically creats all the tools and sign cells
    % in the palette. It also positions all other UI objects properly. 
        % get the definision of the layout
        [mLayout, mSignEntries, mToolEntries] = localDefineLayout();
        
        % change the size of the sign palette to the desired size, place
        % the components, and then change size back.
        setpixelposition(hPalettePanel, [0, 0, mLayout.preferredWidth, mLayout.preferredHeight]);
        
        % create tools
        startY = mLayout.preferredHeight;
        for i=1:mLayout.toolRowNumber
            for j=1:mLayout.toolPerRow
                if ((i-1)*mLayout.toolPerRow + j)>length(mToolEntries)
                    break;
                end
                tool = mToolEntries{(i-1)*mLayout.toolPerRow + j};
                control = uicontrol('Style','ToggleButton',...
                            'Parent',hPalettePanel, ...
                            'TooltipString', tool.Name,...
                            'UserData', tool,...
                            'Units','pixels',...
                            'Position',[mLayout.hgap+(j-1)*(mLayout.toolSize+mLayout.hgap),...
                                        startY- i*(mLayout.toolSize+mLayout.hgap),...
                                        mLayout.toolSize, mLayout.toolSize]);            
                if isfield(tool,'Icon')
                    set(control,'CData',iconRead(tool.Icon));
                end
                if isfield(tool,'Visible')
                    set(control,'Visible',tool.Visible);
                end
                set(control,'units','normalized');
            end
        end

        % create sign cells
        startY = startY - mLayout.toolRowNumber*(mLayout.toolSize+mLayout.vgap);
        for i=1:mLayout.cellRowNumber
            for j=1:mLayout.cellPerRow
                if ((i-1)*mLayout.cellPerRow + j)>length(mSignEntries)
                    break;
                end
                sgn = mSignEntries{(i-1)*mLayout.cellPerRow + j};
                tooltip = mat2str(sgn.Sign);
                if isfield(sgn,'Name')
                    tooltip = sgn.Name;
                end
                control = uicontrol('Style','ToggleButton',...
                            'TooltipString', tooltip,...
                            'String',sgn.Sign,... 
                            'Parent',hPalettePanel, ...
                            'Units','pixels',...
                            'UserData',sgn,... 
                            'Position',[mLayout.hgap+(j-1)*(mLayout.cellSize+mLayout.hgap),...
                                    startY- i*(mLayout.cellSize+mLayout.hgap),...
                                    mLayout.cellSize, mLayout.cellSize]);            
                if isequal(mSelectedSign,get(control,'String'))
                    set(control,'value',1);
                end
                set(control,'units','normalized');
            end
        end
        
        % place sign sample
        startY = startY - mLayout.cellRowNumber*(mLayout.cellSize+mLayout.vgap);
        startX = 2*mLayout.hgap+mLayout.signSampleSize;
        setpixelposition(hSelectedSignText, [mLayout.hgap, (startY-mLayout.signSampleSize), ...
                                              mLayout.signSampleSize,mLayout.signSampleSize]); 
        rgbHeight = floor(mLayout.signSampleSize/3);
        rgbWidth = mLayout.preferredWidth - mLayout.signSampleSize - 3*mLayout.hgap;
        setpixelposition(hSignValueText,   [startX, (startY-rgbHeight), rgbWidth, rgbHeight]); 
                           
        % place More Signs button
        startY = startY - mLayout.signSampleSize - mLayout.vgap;
        setpixelposition(hMoreSignsButton,[mLayout.hgap, (startY-mLayout.moreSignsButtonHeight), ...
                                           mLayout.preferredWidth - 2*mLayout.hgap,mLayout.moreSignsButtonHeight]); 

        % restore palette to the full size                               
        set(hPalettePanel, 'units', 'normalized', 'Position', [0 0 1 1]);
        
        %----------------------------------------------------------------------
        function [layout, signs, tools]=localDefineLayout
        % helper functions that provides the data defining the sign palette    
            signs = localDefineSigns();
            tools = localDefineTools();
            
            layout.hgap = 3;
            layout.vgap = 5;
            layout.cellSize = 16;
            layout.cellPerRow = 8;
            layout.toolSize = 25;
            layout.signSampleSize = 60;
            layout.moreSignsButtonHeight = 25;
            
            % calculate the preferred width and height
            width  =  max([2*layout.signSampleSize,(layout.cellSize+layout.hgap)*layout.cellPerRow]);
            layout.cellRowNumber =  ceil(length(signs)/ceil(width/(layout.cellSize+layout.vgap)));
            layout.toolPerRow =  ceil(width/(layout.toolSize+layout.vgap));
            layout.toolRowNumber =  ceil(length(tools)/ceil(width/(layout.toolSize+layout.vgap)));
            height =  layout.cellRowNumber*(layout.cellSize+layout.vgap) ...
                    + layout.toolRowNumber*(layout.toolSize+layout.vgap) ...
                    + layout.signSampleSize + layout.moreSignsButtonHeight;
            layout.preferredWidth = layout.hgap+width;
            layout.preferredHeight = 2*layout.vgap+height;
        end
        
        %--------------------------------------------------------------------------
        function tools = localDefineTools
        % helper function that defines the tools shown in this sign
        % palette. The 'name' is used to show a tooltip of the tool. The
        % 'callback' is used to provide the function called when the
        % corresponding tool is selected. You can change the tools in the
        % palette by adding/removing entries.
        tools = {struct('Name','Eraser', ...
                        'Icon','eraser.gif',...
                        'Callback', @eraserToolCallback)};
        end
        
        %--------------------------------------------------------------------------
        function signs = localDefineSigns
        % helper function that defines the signs shown in this sign
        % palette. The 'name' is used to show a tooltip of the sign. If it
        % is not provided, the sign value is used as the tooltip. The
        % 'callback' is used to provide the function called when the
        % corresponding sign is selected. You can change the sign values
        % or the number of signs. The palette will adapt to the changes. 
        callback = @signCellCallback; 
        signs = {struct('Sign','A',...
                        'Callback',callback),...
                 struct('Sign','B',...
                        'Callback',callback),...        
                 struct('Sign','C',...
                        'Callback',callback),...
                 struct('Sign','D', ...
                        'Callback',callback),...        
                 struct('Sign','E',...
                        'Callback',callback),...        
                 struct('Sign','F',...
                        'Callback',callback),...
                 struct('Sign','G',...
                        'Callback',callback),... 
                 struct('Sign','H',...
                        'Callback',callback),...
                 struct('Sign','I',...
                        'Callback',callback),...
                 struct('Sign','J',...
                        'Callback',callback),...
                 struct('Sign','K',...
                        'Callback',callback),... 
                 struct('Sign','L',...
                        'Callback',callback),...
                 struct('Sign','M',...
                        'Callback',callback),... 
                 struct('Sign','N',...
                        'Callback',callback),...
                 struct('Sign','O',...
                        'Callback',callback),... 
                 struct('Sign','P',...
                        'Callback',callback),...
                 struct('Sign','Q',...
                        'Callback',callback),... 
                 struct('Sign','R',...
                        'Callback',callback),...
                 struct('Sign','S',...
                        'Callback',callback),... 
                 struct('Sign','T',...
                        'Callback',callback),...
                 struct('Sign','U',...
                        'Callback',callback),...
                 struct('Sign','V',...
                        'Callback',callback),...
                 struct('Sign','W',...
                        'Callback',callback),... 
                 struct('Sign','X',...
                        'Callback',callback),...
                 struct('Sign','Y',...
                        'Callback',callback),... 
                 struct('Sign','Z',...
                        'Callback',callback)};
        end
    end

    %----------------------------------------------------------------------
    function processUserInputs
    % helper function that processes the input property/value pairs 
        % Apply recognizable custom parameter/value pairs
        for index=1:2:length(mInputArgs)
            if length(mInputArgs) < index+1
                break;
            end
            match = find(ismember({mPropertyDefs{:,1}},mInputArgs{index}));
            if ~isempty(match)  
               % Validate input and assign it to a variable if given
               if ~isempty(mPropertyDefs{match,3}) && mPropertyDefs{match,2}(mPropertyDefs{match,1}, mInputArgs{index+1})
                   assignin('caller', mPropertyDefs{match,3}, mInputArgs{index+1}) 
               end
            end
        end        

        if isempty(mPaletteParent)
            mPaletteParent = gcf;
        end
    end

    %----------------------------------------------------------------------
    function isValid = localValidateInput(property,value)
    % helper function that validates the user provided input property/value
    % pairs. You can choose to show warnings or errors here.
        isValid = false;
        switch lower(property)
            case 'parent'
                if ishandle(value) 
                    mPaletteParent = true;
                    isValid =true;
                end
        end
    end
end % end of signPalette

