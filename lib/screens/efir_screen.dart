import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/demo_data.dart';

class EFIRScreen extends StatefulWidget {
  const EFIRScreen({super.key});

  @override
  State<EFIRScreen> createState() => _EFIRScreenState();
}

class _EFIRScreenState extends State<EFIRScreen> {
  final _formKey = GlobalKey<FormState>();
  final _incidentTypeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _witnessController = TextEditingController();
  final _contactController = TextEditingController();
  DateTime? _incidentDate;
  TimeOfDay? _incidentTime;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    final tourist = DemoData.getCurrentTourist();
    _contactController.text = tourist.name;
  }

  @override
  void dispose() {
    _incidentTypeController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _witnessController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: now,
      initialDate: now,
    );
    if (picked != null) setState(() => _incidentDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => _incidentTime = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate() || _incidentDate == null || _incidentTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields.')),
      );
      return;
    }
    setState(() => _submitted = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-FIR Filing'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: _submitted ? _buildSuccess() : _buildForm(),
    );
  }

  Widget _buildSuccess() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, size: 80, color: Colors.green),
            const SizedBox(height: 16),
            Text('E-FIR Submitted', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green.shade700)),
            const SizedBox(height: 8),
            Text('Your report has been logged and assigned a reference number. Authorities will review shortly.', textAlign: TextAlign.center, style: GoogleFonts.poppins()),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Dashboard'),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Incident Details'),
            const SizedBox(height: 12),
            _buildTextField(_incidentTypeController, 'Incident Type', 'e.g., Theft, Harassment', true, icon: Icons.report),
            const SizedBox(height: 12),
            _buildMultiline(_descriptionController, 'Description', 'Provide a clear summary of what happened', true),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _dateTimeBox(
                    label: 'Date',
                    value: _incidentDate == null ? 'Select' : _incidentDate!.toString().substring(0,10),
                    icon: Icons.date_range,
                    onTap: _pickDate,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _dateTimeBox(
                    label: 'Time',
                    value: _incidentTime == null ? 'Select' : _incidentTime!.format(context),
                    icon: Icons.access_time,
                    onTap: _pickTime,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _sectionTitle('Location & Witnesses'),
            const SizedBox(height: 12),
            _buildTextField(_locationController, 'Location', 'Exact spot or landmark', true, icon: Icons.location_on),
            const SizedBox(height: 12),
            _buildMultiline(_witnessController, 'Witnesses (optional)', 'Names / contacts if any', false),
            const SizedBox(height: 20),
            _sectionTitle('Contact & Verification'),
            const SizedBox(height: 12),
            _buildTextField(_contactController, 'Your Name', 'Registered traveller name', true, icon: Icons.person),
            const SizedBox(height: 12),
            CheckboxListTile(
              value: true,
              onChanged: (_) {},
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              title: const Text('I confirm the information provided is accurate to the best of my knowledge.'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                child: const Text('Submit E-FIR'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(
    text,
    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.green.shade800),
  );

  Widget _buildTextField(TextEditingController c, String label, String hint, bool required, {IconData? icon}) {
    return TextFormField(
      controller: c,
      validator: required ? (v) => (v==null || v.trim().isEmpty) ? 'Required' : null : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildMultiline(TextEditingController c, String label, String hint, bool required) {
    return TextFormField(
      controller: c,
      maxLines: 5,
      validator: required ? (v) => (v==null || v.trim().isEmpty) ? 'Required' : null : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        alignLabelWithHint: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _dateTimeBox({required String label, required String value, required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.green.shade700),
            const SizedBox(width: 12),
            Expanded(child: Text('$label: $value')),
          ],
        ),
      ),
    );
  }
}
