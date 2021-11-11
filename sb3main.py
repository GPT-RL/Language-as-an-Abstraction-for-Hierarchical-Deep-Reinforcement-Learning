from clevr_robot_env import ClevrEnv
from stable_baselines3 import DQN, HerReplayBuffer

env = ClevrEnv(
    action_type="perfect",
    obs_type="order_invariant",
    direct_obs=True,
    use_subset_instruction=True,
)

# Available strategies (cf paper): future, final, episode
goal_selection_strategy = 'future' # equivalent to GoalSelectionStrategy.FUTURE

# If True the HER transitions will get sampled online
online_sampling = True

# Initialize the model
# noinspection PyTypeChecker
model = DQN(
    "MultiInputPolicy",
    env,
    replay_buffer_class=HerReplayBuffer,
    # Parameters for HER
    replay_buffer_kwargs=dict(
        n_sampled_goal=4,
        goal_selection_strategy=goal_selection_strategy,
        online_sampling=online_sampling,
        max_episode_length=env.max_episode_steps,
    ),
    verbose=1,
)

# Train the model
model.learn(100000)

model.save("./her_bit_env")
# Because it needs access to `env.compute_reward()`
# HER must be loaded with the env
model = DQN.load('./her_bit_env', env=env)

obs = env.reset()
for _ in range(100):
    action, _ = model.predict(obs, deterministic=True)
    obs, reward, done, _ = env.step(action)

    if done:
        obs = env.reset()
