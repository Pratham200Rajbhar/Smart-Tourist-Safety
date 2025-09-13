import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

// Events
abstract class LocationEvent {}

class StartLocationTracking extends LocationEvent {}

class StopLocationTracking extends LocationEvent {}

class LocationUpdated extends LocationEvent {
  final Position position;
  
  LocationUpdated(this.position);
}

// States
abstract class LocationState {}

class LocationInitial extends LocationState {}

class LocationLoading extends LocationState {}

class LocationEnabled extends LocationState {
  final Position position;
  
  LocationEnabled(this.position);
}

class LocationDisabled extends LocationState {}

class LocationError extends LocationState {
  final String message;
  
  LocationError(this.message);
}

// BLoC
class LocationBloc extends Bloc<LocationEvent, LocationState> {
  LocationBloc() : super(LocationInitial()) {
    on<StartLocationTracking>(_onStartLocationTracking);
    on<StopLocationTracking>(_onStopLocationTracking);
    on<LocationUpdated>(_onLocationUpdated);
  }

  void _onStartLocationTracking(StartLocationTracking event, Emitter<LocationState> emit) async {
    emit(LocationLoading());
    
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        emit(LocationDisabled());
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          emit(LocationError('Location permissions are denied'));
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        emit(LocationError('Location permissions are permanently denied'));
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      emit(LocationEnabled(position));
      
      // Start listening to position updates
      Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).listen((Position position) {
        add(LocationUpdated(position));
      });
      
    } catch (e) {
      emit(LocationError('Failed to get location: $e'));
    }
  }

  void _onStopLocationTracking(StopLocationTracking event, Emitter<LocationState> emit) {
    // In a real app, you would stop the location stream here
    emit(LocationInitial());
  }

  void _onLocationUpdated(LocationUpdated event, Emitter<LocationState> emit) {
    emit(LocationEnabled(event.position));
  }
}