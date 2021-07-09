import { Actor, HttpAgent } from '@dfinity/agent';
import { idlFactory as DTwitter_idl, canisterId as DTwitter_id } from 'dfx-generated/DTwitter';

const agent = new HttpAgent();
const DTwitter = Actor.createActor(DTwitter_idl, { agent, canisterId: DTwitter_id });

document.getElementById("clickMeBtn").addEventListener("click", async () => {
  const name = document.getElementById("name").value.toString();
  const greeting = await DTwitter.greet(name);

  document.getElementById("greeting").innerText = greeting;
});
