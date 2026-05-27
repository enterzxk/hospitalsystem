import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

public class GenPassword {
    public static void main(String[] args) {
        BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
        String sha256Password = "8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92";
        String encoded = encoder.encode(sha256Password);
        System.out.println("BCrypt:");
        System.out.println(encoded);
        System.out.println("Match: " + encoder.matches(sha256Password, encoded));
    }
}
