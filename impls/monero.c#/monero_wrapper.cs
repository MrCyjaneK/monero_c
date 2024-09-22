using Godot;
using System;
using System.Runtime.InteropServices;

public partial class monero_wrapper : Node
{
	public static IntPtr wmPtr = MONERO_WalletManagerFactory_getWalletManager();
	public static IntPtr wPtr;
	public static IntPtr pendingTx;
	public static IntPtr txHistory;
	public string path = "";
	
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
	}
	
	public static bool openWallet(string path, string password) {
		MONERO_WalletManager_createWallet(wmPtr, path, password, "English", 0);
		wPtr = MONERO_WalletManager_openWallet(wmPtr, path, password, 0);
		return MONERO_Wallet_status(wPtr) == 0;
	}

	public static void initWallet(string daemonAddress, bool useSsl, String proxyString) {
	   //MONERO_Wallet_init(string daemon_password, bool use_ssl, bool lightWallet, string proxy_address);
		MONERO_Wallet_init(wPtr, daemonAddress, 0, "", "", useSsl, false, proxyString);
		GD.Print(lastError());
		MONERO_Wallet_init3(wPtr, "", "", "/dev/shm/godot_moneroc.log", false);
		GD.Print(lastError());
		MONERO_Wallet_setTrustedDaemon(wPtr, true);
		GD.Print(lastError());
		MONERO_Wallet_refreshAsync(wPtr);
		GD.Print(lastError());
		MONERO_Wallet_startRefresh(wPtr);
		GD.Print(lastError());
	}
	
	public static void storeWallet() {
		MONERO_Wallet_store(wPtr);
	}
	
	public static string lastError() {
		IntPtr resultPtr = MONERO_Wallet_errorString(wPtr);
		string result = Marshal.PtrToStringAnsi(resultPtr);
		return result;
	}
	
	public static int lastErrorCode() {
		return MONERO_Wallet_status(wPtr);
	}

	public static string lastTxError() {
		IntPtr resultPtr = MONERO_PendingTransaction_errorString(pendingTx);
		string result = Marshal.PtrToStringAnsi(resultPtr);
		return result;
	}

	public static int lastTxErrorCode() {
		return MONERO_PendingTransaction_status(pendingTx);
	}

	public static string getAddress(ulong accountIndex, ulong addressIndex) {
		IntPtr resultPtr = MONERO_Wallet_address(wPtr, accountIndex, addressIndex);
		string result = Marshal.PtrToStringAnsi(resultPtr);
		return result;
	}

	public static ulong getBalance(uint accountIndex) {
		return MONERO_Wallet_balance(wPtr, accountIndex);
	}

	public static void createTransaction(string address, ulong amount) {
		pendingTx = MONERO_Wallet_createTransaction(wPtr, address, "", amount, 0, 0, 0, "", "");
		MONERO_PendingTransaction_commit(pendingTx, "", false);
	}
	
	public static int getTransactionCount() {
		txHistory = MONERO_Wallet_history(wPtr);
		MONERO_TransactionHistory_refresh(txHistory);
		return MONERO_TransactionHistory_count(txHistory);
	}

	public static int getTransactionDirection(int index) {
		txHistory = MONERO_Wallet_history(wPtr);
		IntPtr txPtr = MONERO_TransactionHistory_transaction(txHistory, index);
		return MONERO_TransactionInfo_direction(txPtr);
	}
	
	public static ulong getTransactionAmount(int index) {
		txHistory = MONERO_Wallet_history(wPtr);
		IntPtr txPtr = MONERO_TransactionHistory_transaction(txHistory, index);
		return MONERO_TransactionInfo_amount(txPtr);
	}
	
	public static ulong getTransactionTimestamp(int index) {
		txHistory = MONERO_Wallet_history(wPtr);
		IntPtr txPtr = MONERO_TransactionHistory_transaction(txHistory, index);
		return MONERO_TransactionInfo_timestamp(txPtr);
	}

	[DllImport("/usr/lib/monero_libwallet2_api_c.so")]
	public static extern ulong MONERO_TransactionInfo_timestamp(IntPtr txPtr);

	[DllImport("/usr/lib/monero_libwallet2_api_c.so")]
	public static extern IntPtr MONERO_TransactionHistory_transaction(IntPtr txHistory, int index);

	[DllImport("/usr/lib/monero_libwallet2_api_c.so")]
	public static extern int MONERO_TransactionInfo_direction(IntPtr txPtr);

	[DllImport("/usr/lib/monero_libwallet2_api_c.so")]
	public static extern int MONERO_TransactionHistory_count(IntPtr txHistory);

	[DllImport("/usr/lib/monero_libwallet2_api_c.so")]
	public static extern ulong MONERO_TransactionInfo_amount(IntPtr txPtr);

	[DllImport("/usr/lib/monero_libwallet2_api_c.so")]
	public static extern IntPtr MONERO_Wallet_history(IntPtr wm_ptr);

	[DllImport("/usr/lib/monero_libwallet2_api_c.so")]
	public static extern IntPtr MONERO_TransactionHistory_refresh(IntPtr txHistory);

	[DllImport("/usr/lib/monero_libwallet2_api_c.so")]
	public static extern IntPtr MONERO_WalletManager_createWallet(IntPtr wm_ptr, string path, string password, string language, int networkType);
	
	[DllImport("/usr/lib/monero_libwallet2_api_c.so")]
	public static extern IntPtr MONERO_WalletManager_openWallet(IntPtr wm_ptr, string path, string password, int networkType);

	[DllImport("/usr/lib/monero_libwallet2_api_c.so")]
	public static extern IntPtr MONERO_WalletManagerFactory_getWalletManager();
	
	[DllImport("/usr/lib/monero_libwallet2_api_c.so")]
	public static extern int MONERO_Wallet_status(IntPtr wPtr);

	[DllImport("/usr/lib/monero_libwallet2_api_c.so")]
	public static extern int MONERO_PendingTransaction_status(IntPtr wPtr);
	
	[DllImport("/usr/lib/monero_libwallet2_api_c.so")]
	public static extern bool MONERO_WalletManager_walletExists(IntPtr wmPtr, string path);
	
	[DllImport("/usr/lib/monero_libwallet2_api_c.so")]
	public static extern IntPtr MONERO_Wallet_errorString(IntPtr wPtr);
	
	[DllImport("/usr/lib/monero_libwallet2_api_c.so")]
	public static extern IntPtr MONERO_PendingTransaction_errorString(IntPtr pendingTx);

	[DllImport("/usr/lib/monero_libwallet2_api_c.so")]
	public static extern ulong MONERO_Wallet_balance(IntPtr wPtr, uint accountIndex);
	
	[DllImport("/usr/lib/monero_libwallet2_api_c.so")]
	public static extern IntPtr MONERO_Wallet_address(IntPtr wPtr, ulong accountIndex, ulong addressIndex);
	
	[DllImport("/usr/lib/monero_libwallet2_api_c.so")]
	public static extern IntPtr MONERO_Wallet_createTransaction(IntPtr wallet_ptr, string dst_addr, string payment_id,
													ulong amount, uint mixin_count,
													int pendingTransactionPriority,
													uint subaddr_account,
													string preferredInputs, string separator);

	[DllImport("/usr/lib/monero_libwallet2_api_c.so")]
	public static extern bool MONERO_PendingTransaction_commit(IntPtr pendingTx_ptr, string filename, bool overwrite);

	[DllImport("/usr/lib/monero_libwallet2_api_c.so")]
	public static extern bool MONERO_Wallet_init(IntPtr wallet_ptr, string daemon_address, ulong upper_transaction_size_limit, string daemon_username, string daemon_password, bool use_ssl, bool lightWallet, string proxy_address);

	[DllImport("/usr/lib/monero_libwallet2_api_c.so")]
	public static extern bool MONERO_Wallet_init3(IntPtr wallet_ptr, string argv0, string default_log_base_name, string log_path, bool console);
	
	[DllImport("/usr/lib/monero_libwallet2_api_c.so")]
	public static extern void MONERO_Wallet_setTrustedDaemon(IntPtr wallet_ptr, bool arg);
	
	[DllImport("/usr/lib/monero_libwallet2_api_c.so")]
	public static extern void MONERO_Wallet_startRefresh(IntPtr wallet_ptr);
	
	[DllImport("/usr/lib/monero_libwallet2_api_c.so")]
	public static extern void MONERO_Wallet_refreshAsync(IntPtr wallet_ptr);

	[DllImport("/usr/lib/monero_libwallet2_api_c.so")]
	public static extern bool MONERO_Wallet_store(IntPtr wallet_ptr);
}
