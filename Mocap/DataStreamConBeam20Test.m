clc
clearvars -except iPhi gp 
close all
clear ard

% Se requiere correr modal_control.m primero para obtener la ganancia
sensor=19;
C=iPhi(1:20,1:20);

% Inicialización del Arduino Board
ard=arduino('COM5','UNO');      %hay que revisar en que COM está conectado
pin='D9';                       %Elegir el pin para la señal pwm fija
controlPin='D10';               %Elegir el pin para el control
frequency=100;                  %Frecuencia en Hz
dutyCycle=0.5;                  %Porcentaja del ciclo de trabajo
%Esto configura el pin para mandar un pwm
configurePin(ard,pin,'DigitalOutput'); 
%Calculael perido correspondiente a la frecuencia deseada
period=1/frequency;
%Calcula el tiempo de encendido 
onTime=dutyCycle*period;
%Esto manda la señal PWM a la frecuencia especificada en frequency
writeDigitalPin(ard,pin,1)      %Encender
pause(onTime);                  %Mantiene el pin encendido
writeDigitalPin(ard,pin,0)      %Apaga el pin

% Incializo cosas que necesito para el primer ciclo 
X=zeros(20,1);                  %Esto son posiciones
previousValue=0;                %Esto es para el control
treshold=0.5;                   %Modificar el treshold a conveniencia

%% Opciones del programa
s=typecast(sensor,'int32');
TransmitMulticast = false;
EnableHapticFeedbackTest = false;
HapticOnList = {'ViconAP_001';'ViconAP_002'};
SubjectFilterApplied = false;
bPrintSkippedFrame = false;

% Comprueba si existen estas variables, ya que pueden configurarse mediante la línea de comando al iniciar
% Si ejecuta la secuencia de comandos con la ventana de comandos en Matlab, estas variables del espacio de
% trabajo podrían conservar el valor de las ejecuciones anteriores, incluso si no están configuradas en la 
% ventana de comandos. Por eso añadi clearvars al inicio
if ~exist( 'bReadCentroids' )
  bReadCentroids = false;
end

if ~exist( 'bReadRays' )
  bReadRays = false;
end

if ~exist( 'bTrajectoryIDs' )
  bTrajectoryIDs = false;
end

if ~exist( 'axisMapping' )
  axisMapping = 'ZUp';
end

% example for running from commandline in the ComandWindow in Matlab
% e.g. bLightweightSegment = true;HostName = 'localhost:801';ViconDataStreamSDK_MATLABTest
if ~exist('bLightweightSegment')
  bLightweightSegment = false;
end

% Pass the subjects to be filtered in
% e.g. Subject = {'Subject1'};HostName = 'localhost:801';ViconDataStreamSDK_MATLABTest
EnableSubjectFilter  = exist('subjects');

% Opciones del programa
if ~exist( 'HostName' )
  HostName = 'localhost:801';
end

if exist('undefVar')
  fprintf('Undefined Variable: %s\n', mat2str( undefVar ) );
end

% fprintf( 'Centroids Enabled: %s\n', mat2str( bReadCentroids ) );
% fprintf( 'Rays Enabled: %s\n', mat2str( bReadRays ) );
% fprintf( 'Trajectory IDs Enabled: %s\n', mat2str( bTrajectoryIDs ) );
% fprintf( 'Lightweight Segment Data Enabled: %s\n', mat2str( bLightweightSegment ) );
% fprintf('Axis Mapping: %s\n', axisMapping )

%% Carga el SDK (ESTO ES LO IMPORTANTE)
fprintf( 'Loading SDK...' );
addpath( '..\dotNET' );
dssdkAssembly = which('ViconDataStreamSDK_DotNET.dll');
if dssdkAssembly == ""
  [ file, path ] = uigetfile( '*.dll' );
  if isequal( file, 0 )
    fprintf( 'User canceled' );
    return;
  else
    dssdkAssembly = fullfile( path, file );
  end   
end

NET.addAssembly(dssdkAssembly);
fprintf( 'done\n' );

% Crea un nuevo cliente
MyClient = ViconDataStreamSDK.DotNET.Client();

% Se conecta al servidor
fprintf( 'Connecting to %s ...', HostName );
while ~MyClient.IsConnected().Connected
  % conexión directa
  MyClient.Connect( HostName );
  
  % conexión multicast (aparentemente se puede tener acceso desde otra
  % computadora dentro de la misma red)
  % MyClient.ConnectToMulticast( HostName, '224.0.0.0' );
  
  fprintf( '.' );
end
fprintf( '\n' );

% Enable some different data types
MyClient.EnableSegmentData();
MyClient.EnableMarkerData();
MyClient.EnableUnlabeledMarkerData();
MyClient.EnableDeviceData();
if bReadCentroids
  MyClient.EnableCentroidData();
end
if bReadRays
  MyClient.EnableMarkerRayData();
end

if bLightweightSegment
  MyClient.DisableLightweightSegmentData();
  Output_EnableLightweightSegment = MyClient.EnableLightweightSegmentData();
  if Output_EnableLightweightSegment.Result ~= ViconDataStreamSDK.DotNET.Result.Success
    fprintf( 'Server does not support lightweight segment data.\n' );
  end
end

fprintf( 'Segment Data Enabled: %s\n',          AdaptBool( MyClient.IsSegmentDataEnabled().Enabled ) );
fprintf( 'Marker Data Enabled: %s\n',           AdaptBool( MyClient.IsMarkerDataEnabled().Enabled ) );
fprintf( 'Unlabeled Marker Data Enabled: %s\n', AdaptBool( MyClient.IsUnlabeledMarkerDataEnabled().Enabled ) );
fprintf( 'Device Data Enabled: %s\n',           AdaptBool( MyClient.IsDeviceDataEnabled().Enabled ) );
fprintf( 'Centroid Data Enabled: %s\n',         AdaptBool( MyClient.IsCentroidDataEnabled().Enabled ) );
fprintf( 'Marker Ray Data Enabled: %s\n',       AdaptBool( MyClient.IsMarkerRayDataEnabled().Enabled ) );

MyClient.SetBufferSize(1)
% % Establece el modo de transmisión 
MyClient.SetStreamMode( ViconDataStreamSDK.DotNET.StreamMode.ClientPull  );%(siempre utilizó esta)
% % MyClient.SetStreamMode( StreamMode.ClientPullPreFetch );
% % MyClient.SetStreamMode( StreamMode.ServerPush );

% % Set the global up axis
if axisMapping == 'XUp'
  MyClient.SetAxisMapping( ViconDataStreamSDK.DotNET.Direction.Up, ...
                           ViconDataStreamSDK.DotNET.Direction.Forward,      ...
                           ViconDataStreamSDK.DotNET.Direction.Left ); % X-up
elseif axisMapping == 'YUp'
  MyClient.SetAxisMapping(  ViconDataStreamSDK.DotNET.Direction.Forward, ...
                          ViconDataStreamSDK.DotNET.Direction.Up,    ...
                          ViconDataStreamSDK.DotNET.Direction.Right );    % Y-up
else
  MyClient.SetAxisMapping(  ViconDataStreamSDK.DotNET.Direction.Forward, ...
                          ViconDataStreamSDK.DotNET.Direction.Left,    ...
                          ViconDataStreamSDK.DotNET.Direction.Up );    % Z-up
end

Output_GetAxisMapping = MyClient.GetAxisMapping();
fprintf( 'Axis Mapping: X-%s Y-%s Z-%s\n', char( Output_GetAxisMapping.XAxis.ToString() ), ...
                                           char( Output_GetAxisMapping.YAxis.ToString() ), ...
                                           char( Output_GetAxisMapping.ZAxis.ToString() ) );
  
if TransmitMulticast
  MyClient.StartTransmittingMulticast( 'localhost', '224.0.0.0' );
end  

Frame = -1;
SkippedFrames = [];
Counter = 1;

tStart = tic;

contador=1;



%% Este es el ciclo for principal, no se detiene hasta que se para el programa
%%%%%%%%%% aquí es donde está mandando a llamar la posición de los
%%%%%%%%%% marcadores, y donde tiene que ocurrir el control

for i=1:100
%   drawnow limitrate;
  Counter = Counter + 1;
  
  % Cuando no está funcionando nexus, este while me imprime puntos
  % suspensivos
  fprintf( 'Waiting for new frame...' );
  while MyClient.GetFrame().Result ~= ViconDataStreamSDK.DotNET.Result.Success
    fprintf( '.' );
  end
  fprintf( '\n' );  
  

  % Get the frame number
  Output_GetFrameNumber = MyClient.GetFrameNumber();
  if Frame ~= -1
    while Output_GetFrameNumber.FrameNumber > Frame + 1
      SkippedFrames = [SkippedFrames Frame+1];
      if bPrintSkippedFrame
        fprintf( 'Skipped frame: %d\n', Frame+1 );      
      end
      Frame = Frame + 1;
    end
  end
  Frame = Output_GetFrameNumber.FrameNumber;  
%   fprintf( 'Frame Number: %d\n', Output_GetFrameNumber.FrameNumber );

  % Get the frame rate
  Output_GetFrameRate = MyClient.GetFrameRate();
  fprintf( 'Frame rate: %g\n', Output_GetFrameRate.FrameRateHz );


  fprintf( '\n' );

  % Cuenta el número de subjetcs (si lo borro puede ocasionar algÚn
  % problema cuando tengo marcado el subject)
  SubjectCount = MyClient.GetSubjectCount().SubjectCount;
  %   fprintf( 'Subjects (%d):\n', SubjectCount );
  for SubjectIndex = 0:typecast( SubjectCount, 'int32' ) -1
    fprintf( '  Subject #%d\n', SubjectIndex );
    
    % Get the subject name
    SubjectName = MyClient.GetSubjectName( typecast( SubjectIndex, 'uint32') ).SubjectName;
    fprintf( '    Name: %s\n', char(SubjectName) );
    
    % Get the root segment
    RootSegment = MyClient.GetSubjectRootSegmentName( SubjectName ).SegmentName;
    fprintf( '    Root Segment: %s\n', char(RootSegment) );

    % Count the number of segments
    SegmentCount = MyClient.GetSegmentCount( SubjectName ).SegmentCount;
    fprintf( '    Segments (%d):\n', SegmentCount );
    for SegmentIndex = 0:typecast( SegmentCount , 'int32' )-1
      fprintf( '      Segment #%d\n', SegmentIndex );
      
      % Get the segment name
      SegmentName = MyClient.GetSegmentName( SubjectName, typecast( SegmentIndex, 'uint32') ).SegmentName;
      fprintf( '        Name: %s\n', char( SegmentName ) );
      
      % Get the segment parent
      SegmentParentName = MyClient.GetSegmentParentName( SubjectName, SegmentName ).SegmentName;
      fprintf( '        Parent: %s\n',  char( SegmentParentName ) );

      % Get the segment's children
      ChildCount = MyClient.GetSegmentChildCount( SubjectName, SegmentName ).SegmentCount;
      fprintf( '     Children (%d):\n', ChildCount );
      for ChildIndex = 0:typecast( ChildCount, 'int32' )-1
        ChildName = MyClient.GetSegmentChildName( SubjectName, SegmentName, typecast( ChildIndex, 'uint32' ) ).SegmentName;
        fprintf( '       %s\n', char( ChildName ) );
      end% for  

      % Get the static segment translation
      Output_GetSegmentStaticTranslation = MyClient.GetSegmentStaticTranslation( SubjectName, SegmentName );
      fprintf( '        Static Translation: (%g, %g, %g)\n',                  ...
                         Output_GetSegmentStaticTranslation.Translation( 1 ), ...
                         Output_GetSegmentStaticTranslation.Translation( 2 ), ...
                         Output_GetSegmentStaticTranslation.Translation( 3 ) );
      
      % Get the global segment translation
      Output_GetSegmentGlobalTranslation = MyClient.GetSegmentGlobalTranslation( SubjectName, SegmentName );
      fprintf( '        Global Translation: (%g, %g, %g) %s\n',               ...
                         Output_GetSegmentGlobalTranslation.Translation( 1 ), ...
                         Output_GetSegmentGlobalTranslation.Translation( 2 ), ...
                         Output_GetSegmentGlobalTranslation.Translation( 3 ), ...
                         AdaptBool( Output_GetSegmentGlobalTranslation.Occluded ) );
    end% SegmentIndex
    
    % Cuenta el número de marcadores 
    MarkerCount = MyClient.GetMarkerCount( SubjectName ).MarkerCount;
    fprintf( '    Markers (%d):\n', MarkerCount );
    for MarkerIndex = 0:typecast( MarkerCount, 'int32' )-1
      % Get the marker name
      MarkerName = MyClient.GetMarkerName( SubjectName, typecast( MarkerIndex,'uint32') ).MarkerName;

      % Get the marker parent
      MarkerParentName = MyClient.GetMarkerParentName( SubjectName, MarkerName ).SegmentName;

      % Get the global marker translation
      Output_GetMarkerGlobalTranslation = MyClient.GetMarkerGlobalTranslation( SubjectName, MarkerName );

      fprintf( '      Marker #%d: %s (%g, %g, %g) %s\n',                     ...
                         MarkerIndex,                                    ...
                         char( MarkerName ),                                         ...
                         Output_GetMarkerGlobalTranslation.Translation( 1 ), ...
                         Output_GetMarkerGlobalTranslation.Translation( 2 ), ...
                         Output_GetMarkerGlobalTranslation.Translation( 3 ), ...
                         AdaptBool( Output_GetMarkerGlobalTranslation.Occluded ) );
    end% MarkerIndex
    
  end% SubjectIndex

  
  %% Obtener los marcadores sin etiquetar
  UnlabeledMarkerCount = MyClient.GetUnlabeledMarkerCount().MarkerCount;
%   fprintf( '  Unlabeled Markers (%d):\n', UnlabeledMarkerCount );
  for UnlabeledMarkerIndex = 0:typecast( UnlabeledMarkerCount , 'int32' )- 1
    % Get the global marker translation
    Output_GetUnlabeledMarkerGlobalTranslation = MyClient.GetUnlabeledMarkerGlobalTranslation( typecast(UnlabeledMarkerIndex,'uint32') );
    
    

    %%%%%%%%%%%%%%%%%%%% AQUÍ  guardo los datos de movimiento %%%%%%%%%%%%%%%%%%%%%
    X(UnlabeledMarkerIndex+1,contador)=Output_GetUnlabeledMarkerGlobalTranslation.Translation(1);
    
%     Un(UnlabeledMarkerIndex+1,contador)=u;
  end% UnlabeledMarkerIndex

   
%% Obtener los marcadores etiquetados
  LabeledMarkerCount = MyClient.GetLabeledMarkerCount().MarkerCount;
%   fprintf( '  Labeled Markers (%d):\n', LabeledMarkerCount );
  for LabeledMarkerIndex = 0:typecast( LabeledMarkerCount, 'int32' ) -1
    % Get the global marker translation
    Output_GetLabeledMarkerGlobalTranslation = MyClient.GetLabeledMarkerGlobalTranslation( typecast( LabeledMarkerIndex,'uint32') );

    X(LabeledMarkerIndex+1,contador)=Output_GetUnlabeledMarkerGlobalTranslation.Translation(1);
  end% LabeledMarkerIndex

%% Este es el control
    
    y=C*X(:,contador); %se multiplica para obtener la posición modal
    u=-gp*y(1);        %El control se multiplica por y(1) porque es el primer modo
    Un(1,contador)=u; %Esto solo es para graficar

    %%%% Mandar el control por Arduino
    currentValue=u;
    % si el control aumenta, aumenta el voltaje y si baja baja el voltaje
    if currentValue > previousValue + treshold
        writeDigitalPin(ard,controlPin,1)
    elseif currentValue < previousValue - treshold
        writeDigitalPin(ard,controlPin,0)
    end
   
    %Almacena el valor actual como el anterior (para poder comparar)
    previousValue=currentValue;

    %%%%%%%% Guardo los datos del tiempo para poder hacer las graficas con
    %%%%%%%% respecto al tiempo y no contra el contador
    tEnd = toc( tStart );
    tiempo(1,contador)=tEnd;

    contador=contador+1;

    i=i+1;
end% Termina el ciclo principal


if TransmitMulticast
  MyClient.StopTransmittingMulticast();
end  
% Desconectar y desechar
MyClient.Disconnect();



%% Ploteos 

%que marcador se va a plotear 
% marcador = 19;
% 
% figure
% plot(tiempo(1,2:end),X(marcador,2:end),'r')
%  
% figure
% plot(tiempo(1,2:end),Un(1,2:end),'g')

