class ApiGateway {
  // Authentication
  static const LOGIN_WITH_EMAIL = '/Auth/Login';
  static const REGISTER = '/Auth/Register';
  static const VERIFY = '/Auth/Verify';
  static const FORGOT_PASSWORD = '/Auth/ForgotPassword';
  static const CHANGE_PASSWORD = '/Auth/ChangePassword';

  // User
  static const GET_PROFILE = '/User/GetInfo';
  static const UPDATE_PROFILE = '/User/Update';
  static const BUY_POINT = '/User/BuyPoint';
  static const ADD_ADDRESS = '/User/AddAddress';
  static const DELETE_ADDRESS = '/User/DeleteAddress?id=';

  // Device
  static const CREATE_DEVICE = '/Device/Create';
  static const DELETE_DEVICE = '/Device/Delete?deviceUUid=';

  // Transport
  static const REGISTER_TRANSPORT = '/Transport/Create';

  // Merchant
  static const GET_MERCHANT = '/Merchant/GetInfo';
  static const CREATE_MERCHANT = '/Merchant/Create';
  static const UPDATE_MERCHANT = '/Merchant/Update';

  // Group Product
  static const CREATE_GROUP_PRODUCT = '/GroupProduct/Create';
  static const UPDATE_GROUP_PRODUCT = '/GroupProduct/Update';
  static const GET_GROUP_PRODUCT = '/GroupProduct/GetAll?idMerchant=';
  static const DELETE_GROUP_PRODUCT = '/GroupProduct/Delete?id=';

  // Product
  static const CREATE_PRODUCT = '/Product/Create';
  static const UPDATE_PRODUCT = '/Product/Update';
  static const DELETE_PRODUCT = '/Product/Delete?id=';
  static const GET_PRODUCT_BY_MERCHANT = '/Product/GetProductByMerchant?id=';
  static const GET_PRODUCT_BY_GROUP = '/Product/GetProductByGroup?id=';
}
