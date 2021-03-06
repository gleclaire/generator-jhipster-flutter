import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:<%= appsName %>/bloc/app/app_bloc.dart';
import 'package:<%= appsName %>/bloc/authentication/authentication_bloc.dart';
import 'package:<%= appsName %>/generated/i18n.dart';
import 'package:<%= appsName %>/utils/preferences.dart';

import '../widgets/app_icon_widget.dart';
import '../widgets/empty_app_bar_widget.dart';
import '../widgets/global_methods.dart';
import '../widgets/progress_indicator_widget.dart';
import '../widgets/rounded_button_widget.dart';
import '../widgets/textfield_widget.dart';


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //text controllers
  TextEditingController _userEmailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

BuildContext _context;
  //focus node
  FocusNode _passwordFocusNode;

//form key
 final _formKey = GlobalKey<FormState>();

  //store
  final _authBloc = AuthenticationStore();

  final _appBloc = AppStore();

  @override
  void initState() {
    super.initState();

    _passwordFocusNode = FocusNode();

    _userEmailController.addListener(() {
      //this will be called whenever user types in some value
      _authBloc.setUserId(_userEmailController.text);
    });
    _passwordController.addListener(() {
      //this will be called whenever user types in some value
      _authBloc.setPassword(_passwordController.text);
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is removed from the Widget tree
    _userEmailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

     _context = context;
    return Scaffold(
      primary: true,
      appBar: EmptyAppBar(),
      body: _buildBody(),
    );
  }

  Material _buildBody() {
    return Material(
      child: Stack(
        children: <Widget>[
          OrientationBuilder(
            builder: (context, orientation) {
              //variable to hold widget
              var child;

              //check to see whether device is in landscape or portrait
              //load widgets based on device orientation
              orientation == Orientation.landscape
                  ? child = Row(
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: _buildLeftSide(),
                        ),
                        Expanded(
                          flex: 1,
                          child: _buildRightSide(),
                        ),
                      ],
                    )
                  : child = Center(child: _buildRightSide());
              return child;
            },
          ),
          Observer(
            name: 'loading',
            builder: (context) {
              return Visibility(
                visible: _authBloc.loading,
                child: CustomProgressIndicatorWidget(),
              );
            },
          ),
        ],
      ),
    );
  }

   Widget _buildLeftSide() => SizedBox.expand(
      child: Image.asset(Preferences.login_image,
        fit: BoxFit.cover)
  );


  Widget _buildRightSide() => Form(
     key: _formKey,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AppIconWidget(image: Preferences.app_icon),
              SizedBox(height: 24.0),
              _buildUserIdField(),
              _buildPasswordField(),
              _buildForgotPasswordButton(),
              _buildSignInButton(),
            ],
          ),
        ),
      ),
  );


  Widget _buildUserIdField() => TextFieldWidget(
          key: Key('user_id'),
          hint:  S.of(context).email,
          inputType: TextInputType.emailAddress,
          icon: Icons.person,
          iconColor: Colors.black54,
          textController: _userEmailController,
          inputAction: TextInputAction.next,
          onFieldSubmitted: (value) {
            FocusScope.of(context).requestFocus(_passwordFocusNode);
          },
          errorText: _authBloc.userMessage,
  );


  Widget _buildPasswordField() => TextFieldWidget(
          key: Key('user_password'),
          hint: S.of(context).password,
          isObscure: true,
          padding: EdgeInsets.only(top: 16.0),
          icon: Icons.lock,
          iconColor: Colors.black54,
          textController: _passwordController,
          focusNode: _passwordFocusNode,
          errorText: _authBloc.passwordMessage,
  );


  Widget _buildForgotPasswordButton() => Align(
      alignment: FractionalOffset.centerRight,
      child: FlatButton(
        key: Key('user_forgot_password'),
        padding: EdgeInsets.all(0.0),
        child: Text(
          S.of(_context).forgot_password,
          style: Theme.of(_context)
              .textTheme
              .caption
              .copyWith(color: Colors.orangeAccent),
        ),
        onPressed: () => _authBloc.forgotPassword()
      )
  );

  Widget _buildSignInButton() => RoundedButtonWidget(
      key: Key('user_sign_button'),
      buttonText: S.of(_context).sign_in,
      buttonColor:  Theme.of(context).buttonColor,
      textColor: Theme.of(context).textTheme.button.color,
      onPressed: ()=> _authBloc.login()
    );

}
