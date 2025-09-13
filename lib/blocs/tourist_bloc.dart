import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/tourist_models.dart';
import '../models/demo_data.dart';
import '../utils/app_constants.dart';

// Events
abstract class TouristEvent {}

class LoadTourists extends TouristEvent {}

class UpdateTouristLocation extends TouristEvent {
  final double lat;
  final double lng;
  
  UpdateTouristLocation(this.lat, this.lng);
}

class SendSOS extends TouristEvent {
  final double lat;
  final double lng;
  
  SendSOS(this.lat, this.lng);
}

class GenerateDigitalId extends TouristEvent {
  final String name;
  
  GenerateDigitalId(this.name);
}

// States
abstract class TouristState {}

class TouristInitial extends TouristState {}

class TouristLoading extends TouristState {}

class TouristLoaded extends TouristState {
  final List<TouristGroup> groups;
  final Tourist? currentTourist;
  final List<SOSAlert> sosAlerts;
  
  TouristLoaded({
    required this.groups,
    this.currentTourist,
    required this.sosAlerts,
  });
}

class DigitalIdGenerated extends TouristState {
  final Tourist tourist;
  
  DigitalIdGenerated(this.tourist);
}

class SOSSent extends TouristState {
  final SOSAlert alert;
  
  SOSSent(this.alert);
}

class DangerZoneAlert extends TouristState {
  final String message;
  final Tourist tourist;
  
  DangerZoneAlert(this.message, this.tourist);
}

class TouristError extends TouristState {
  final String message;
  
  TouristError(this.message);
}

// BLoC
class TouristBloc extends Bloc<TouristEvent, TouristState> {
  TouristBloc() : super(TouristInitial()) {
    on<LoadTourists>(_onLoadTourists);
    on<UpdateTouristLocation>(_onUpdateTouristLocation);
    on<SendSOS>(_onSendSOS);
    on<GenerateDigitalId>(_onGenerateDigitalId);
  }

  void _onLoadTourists(LoadTourists event, Emitter<TouristState> emit) {
    emit(TouristLoading());
    
    try {
      emit(TouristLoaded(
        groups: DemoData.touristGroups,
        currentTourist: DemoData.currentTourist,
        sosAlerts: DemoData.sosAlerts,
      ));
    } catch (e) {
      emit(TouristError('Failed to load tourist data: $e'));
    }
  }

  void _onUpdateTouristLocation(UpdateTouristLocation event, Emitter<TouristState> emit) {
    try {
      final updatedTourist = DemoData.currentTourist.copyWith(
        lat: event.lat,
        lng: event.lng,
        lastSeen: DateTime.now(),
        isInDangerZone: DemoData.isInDangerZone(event.lat, event.lng),
      );
      
      DemoData.currentTourist = updatedTourist;
      
      if (updatedTourist.isInDangerZone) {
        emit(DangerZoneAlert(
          "⚠️ You are in a Risky Area! Return to Safe Zone.",
          updatedTourist,
        ));
      }
      
      emit(TouristLoaded(
        groups: DemoData.touristGroups,
        currentTourist: updatedTourist,
        sosAlerts: DemoData.sosAlerts,
      ));
    } catch (e) {
      emit(TouristError('Failed to update location: $e'));
    }
  }

  void _onSendSOS(SendSOS event, Emitter<TouristState> emit) {
    try {
      final sosAlert = SOSAlert(
        id: "sos_${DateTime.now().millisecondsSinceEpoch}",
        touristId: DemoData.currentTourist.id,
        touristName: DemoData.currentTourist.name,
        digitalId: DemoData.currentTourist.digitalId,
        lat: event.lat,
        lng: event.lng,
        timestamp: DateTime.now(),
        severity: "high",
        status: "active",
      );
      
      DemoData.sosAlerts.insert(0, sosAlert);
      
      emit(SOSSent(sosAlert));
    } catch (e) {
      emit(TouristError('Failed to send SOS: $e'));
    }
  }

  void _onGenerateDigitalId(GenerateDigitalId event, Emitter<TouristState> emit) {
    try {
      final digitalId = "${AppConstants.digitalIdPrefix}${DateTime.now().millisecondsSinceEpoch}";
      final tourist = Tourist(
        id: "user_${DateTime.now().millisecondsSinceEpoch}",
        name: event.name,
        digitalId: digitalId,
        lat: AppConstants.defaultLat,
        lng: AppConstants.defaultLng,
        lastSeen: DateTime.now(),
      );
      
      DemoData.currentTourist = tourist;
      
      emit(DigitalIdGenerated(tourist));
    } catch (e) {
      emit(TouristError('Failed to generate digital ID: $e'));
    }
  }
}