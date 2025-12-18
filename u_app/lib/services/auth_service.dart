import 'package:graphql_flutter/graphql_flutter.dart';

class AuthService {
  // 1. La dirección secreta para que el Emulador hable con Django
  // Si usas celular físico, aquí iría la IP de tu PC (ej: 192.168.1.50)
  static final HttpLink httpLink = HttpLink('http://192.168.0.104:8000/graphql/');

  static final GraphQLClient client = GraphQLClient(
    link: httpLink,
    cache: GraphQLCache(),
  );

  // 2. La función que envía la Matrícula y Contraseña
  Future<String?> login(String matricula, String password) async {
    
    // Esta es la carta que enviamos a Django (la misma que probamos en el navegador)
    const String loginMutation = """
      mutation(\$matricula: String!, \$password: String!) {
        loginEstudiante(matricula: \$matricula, password: \$password) {
          token
          error
        }
      }
    """;

    final QueryResult result = await client.mutate(
      MutationOptions(
        document: gql(loginMutation),
        variables: {
          'matricula': matricula,
          'password': password,
        },
      ),
    );

    // 3. Revisamos qué respondió el servidor
    if (result.hasException) {
      print("Error de conexión: ${result.exception.toString()}");
      return "Error de conexión con el servidor";
    }

    final data = result.data?['loginEstudiante'];
    
    if (data['error'] != null) {
      return data['error']; // "Credenciales incorrectas", etc.
    }

    if (data['token'] != null) {
      print("¡LOGIN EXITOSO! Token: ${data['token']}");
      return null; // Null significa "Cero errores, todo perfecto"
    }

    return "Error desconocido";
  }
  // función para registrar asistencia
  Future<String?> registrarAsistencia(String matricula) async {
    const String mutation = """
      mutation(\$matricula: String!) {
        registrarAsistencia(matricula: \$matricula) {
          success
          message
        }
      }
    """;

    final QueryResult result = await client.mutate(
      MutationOptions(
        document: gql(mutation),
        variables: {'matricula': matricula},
      ),
    );

    if (result.hasException) {
      return "Error de conexión al registrar";
    }

    final data = result.data?['registrarAsistencia'];
    
    if (data['success'] == true) {
      return null; // Null = correcto
    } else {
      return data['message'] ?? "Error desconocido";
    }
  }
}