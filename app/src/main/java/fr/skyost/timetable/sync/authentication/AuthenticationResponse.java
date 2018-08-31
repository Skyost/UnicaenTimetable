package fr.skyost.timetable.sync.authentication;

public class AuthenticationResponse {

	private int result;
	private Exception ex;

	private String username;
	private String password;

	AuthenticationResponse(final int result) {
		this(result, null);
	}

	AuthenticationResponse(final int result, final Exception ex) {
		this(result, ex, null, null);
	}

	AuthenticationResponse(final int result, final Exception ex, final String username, final String password) {
		this.result = result;
		this.ex = ex;
		this.username = username;
		this.password = password;
	}

	public Integer getResult() {
		return result;
	}

	public void setResult(final int result) {
		this.result = result;
	}

	public Exception getException() {
		return ex;
	}

	public void setException(final Exception ex) {
		this.ex = ex;
	}

	public String getUsername() {
		return username;
	}

	public void setUsername(final String username) {
		this.username = username;
	}

	public String getPassword() {
		return password;
	}

	public void setPassword(final String password) {
		this.password = password;
	}

}