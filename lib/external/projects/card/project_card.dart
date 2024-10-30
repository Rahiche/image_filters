import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_shaders/flutter_shaders.dart';
import 'package:image_filters/external/projects/card/project_card_constants.dart';
import 'package:image_filters/external/projects/card/shader_helper.dart';
import 'package:image_filters/external/projects/delete_project_dialog.dart';

class ProjectCard extends StatefulWidget {
  const ProjectCard({
    super.key,
    required this.child,
    required this.onDelete,
  });

  final Widget child;
  final VoidCallback onDelete;

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard>
    with TickerProviderStateMixin {
  final double cornerRadius = 16.0;

  late final AnimationController _animation;
  late double _width;

  bool _isDialogShown = false;

  @override
  void initState() {
    super.initState();
    _animation = AnimationController.unbounded(
      vsync: this,
      duration: ProjectCardConstants.animationDuration,
    );
    _animation.value = 0.0;
  }

  Future<void> _showCupertinoDialog() async {
    setState(() {
      _isDialogShown = true;
    });
    await showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return DeleteProjectDialog(
          onCancel: _handleCancel,
          onDelete: _handleDelete,
        );
      },
    );
    setState(() {
      _isDialogShown = false;
    });
  }

  Future<void> _handleCancel() async {
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop();
    await _animation.animateTo(
      0,
      duration: ProjectCardConstants.pauseAnimationDuration,
    );
  }

  Future<void> _handleDelete() async {
    HapticFeedback.heavyImpact();
    Navigator.of(context).pop();
    await _animation.animateTo(
      0,
      duration: ProjectCardConstants.deleteAnimationDuration,
    );
    widget.onDelete();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    _width = context.size!.width;
    final double newPointer =
        _animation.value + details.primaryDelta! * _width / 200;
    _animation.value = newPointer;
    final double value = _animation.value + _width;

    if (value < -ProjectCardConstants.dialogThreshold && !_isDialogShown) {
      _showCupertinoDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: (_) => {},
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: (_) => _stopAudioAndReset(),
      onHorizontalDragCancel: _resetAnimation,
      child: AnimatedBuilder(
        animation: _animation,
        builder: _buildAnimatedCard,
      ),
    );
  }

  Widget _buildAnimatedCard(BuildContext context, Widget? child) {
    return ShaderBuilder(
      (context, shader, _) {
        return AnimatedSampler(
          (image, size, canvas) {
            ShaderHelper.configureShader(shader, size, image, _animation.value);
            ShaderHelper.drawShaderRect(shader, size, canvas);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: ProjectCardConstants.cornerRadius,
            ),
            child: widget.child,
          ),
        );
      },
      assetKey: ProjectCardConstants.shaderAssetKey,
    );
  }

  Future<void> _stopAudioAndReset() async {
    if (!_isDialogShown) {
      _resetAnimation();
    }
  }

  void _resetAnimation() {
    HapticFeedback.selectionClick();
    if (!_isDialogShown) {
      _animation.animateTo(0);
    }
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }
}
